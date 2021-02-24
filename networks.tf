#Create a VPC in ca-central-1
resource "aws_vpc" "vpc_master" {
  provider             = aws.region-master
  cidr_block           = "10.10.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "master-vpc-jenkins"
  }
}

#Create a VPC in us-east-1
resource "aws_vpc" "vpc_master_virgina" {
  provider             = aws.region-worker
  cidr_block           = "10.20.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "worker-vpc-jenkins"
  }
}

#Create IGW in ca-central-1
resource "aws_internet_gateway" "igw" {
  provider = aws.region-master
  vpc_id   = aws_vpc.vpc_master.id
}

#Create IGW in us-east-1
resource "aws_internet_gateway" "igw-virgina" {
  provider = aws.region-worker
  vpc_id   = aws_vpc.vpc_master_virgina.id
}

#Get all available AZ's in VPC for mater region
data "aws_availability_zones" "azs" {
  provider = aws.region-master
  state    = "available"
}

#Create Subnet #1 in ca-central-1
resource "aws_subnet" "subnet_1" {
  provider          = aws.region-master
  availability_zone = element(data.aws_availability_zones.azs.names, 0)
  vpc_id            = aws_vpc.vpc_master.id
  cidr_block        = "10.10.1.0/24"
}

#Create Subnet #2 in ca-central-1
resource "aws_subnet" "subnet_2" {
  provider          = aws.region-master
  availability_zone = element(data.aws_availability_zones.azs.names, 1)
  vpc_id            = aws_vpc.vpc_master.id
  cidr_block        = "10.10.2.0/24"
}

#Create Subnet in us-east-1
resource "aws_subnet" "subnet_1_virgina" {
  provider   = aws.region-worker
  vpc_id     = aws_vpc.vpc_master_virgina.id
  cidr_block = "10.20.1.0/24"
}

#Initiate Peering connection request form ca-central-1
resource "aws_vpc_peering_connection" "cacentral1-useast1" {
  provider    = aws.region-master
  peer_vpc_id = aws_vpc.vpc_master_virgina.id
  vpc_id      = aws_vpc.vpc_master.id
  peer_region = var.region-worker
}

#Accept VPC peering request in us-east-1 from ca-central-1
resource "aws_vpc_peering_connection_accepter" "accept_peering" {
  provider                  = aws.region-worker
  vpc_peering_connection_id = aws_vpc_peering_connection.cacentral1-useast1.id
  auto_accept               = true
}

#Create routing table in ca-central-1
resource "aws_route_table" "internet_route" {
  provider = aws.region-master
  vpc_id   = aws_vpc.vpc_master.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  route {
    cidr_block                = "10.20.1.0/24"
    vpc_peering_connection_id = aws_vpc_peering_connection.cacentral1-useast1.id
  }
  lifecycle {
    ignore_changes = all
  }
  tags = {
    Name = "Master-Region-RT"
  }
}

#Overwrite default route table of VPC(Master) with our route tabl entries
resource "aws_main_route_table_association" "set-master-default-rt-assoc" {
  provider       = aws.region-master
  vpc_id         = aws_vpc.vpc_master.id
  route_table_id = aws_route_table.internet_route.id
}

#Create route table in us-east-1
resource "aws_route_table" "internet_route_virgina" {
  provider = aws.region-worker
  vpc_id   = aws_vpc.vpc_master_virgina.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-virgina.id
  }
  route {
    cidr_block                = "10.10.1.0/24"
    vpc_peering_connection_id = aws_vpc_peering_connection.cacentral1-useast1.id
  }
  lifecycle {
    ignore_changes = all
  }
  tags = {
    "Name" = "Worker-Region-RT"
  }
}

#Overwrite default route table of VPC(Worker) with our route tabl entries
resource "aws_main_route_table_association" "set-worker-default-rt-assoc" {
  provider       = aws.region-worker
  vpc_id         = aws_vpc.vpc_master_virgina.id
  route_table_id = aws_route_table.internet_route_virgina.id
}