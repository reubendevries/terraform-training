variable "profile" {
  type    = string
  default = "default"
}
variable "region-master" {
  type    = string
  default = "us-east-1"
}
variable "region-worker" {
  type    = string
  default = "us-west-2"
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
variable "webserver-port" {
  type    = number
  default = 80
}
variable "dns-name" {
  type    = string
  default = "<public-hosted-zone-name-ending-with-dot>"
}