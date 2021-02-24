variable "profile" {
  type    = string
  default = "default"
}
variable "region-master" {
  type    = string
  default = "ca-central-1"
}
variable "region-worker" {
  type    = string
  default = "us-east-1"
}
variable "external-ip" {
  type    = string
  default = "207.194.3.82/32"
}
variable "instance-type" {
  type    = string
  default = "t3.micro"
}
variable "workers-count" {
  type    = number
  default = 1
}