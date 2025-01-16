variable "profile" {
  type    = string
  default = "default"
}
variable "region-master" {
  type    = string
  default = "ap-southeast-2"
}
variable "region-worker" {
  type    = string
  default = "ap-southeast-1"
}
variable "external_ip" {
  type    = string
  default = "0.0.0.0/0"
}
variable "workers-count" {
  type    = number
  default = 1
}
variable "instance-type" {
  type    = string
  default = "t2.micro"
}
variable "instance-type-master" {
  type    = string
  default = "t3.large"
}
variable "webserver-port" {
  type    = number
  default = 80
}
variable "site-name" {
  type    = list(string)
  default = ["furnitureapp","furnitureadmin"]
}
variable "dns-name" {
  type    = string
  default = "khacthienit.click."
}
variable "cidr_block_master_vpc" {
  type    = string
  default = "10.0.0.0/16"
}
variable "cidr_block_worker_vpc" {
  type    = string
  default = "192.168.0.0/16"
}
variable "cidr_block_master_subnet_1" {
  type    = string
  default = "10.0.1.0/24"
}
variable "cidr_block_master_subnet_2" {
  type    = string
  default = "10.0.2.0/24"
}
variable "cidr_block_master_subnet_3" {
  type    = string
  default = "10.0.3.0/24"
}
variable "cidr_block_master_subnet_4" {
  type    = string
  default = "10.0.4.0/24"
}
variable "cidr_block_worker_subnet_1" {
  type    = string
  default = "192.168.1.0/24"
}
variable "ami_master" {
  type    = string
  default = "/aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id"
}
variable "ami_worker" {
  type    = string
  default = "/aws/service/canonical/ubuntu/server/20.04/stable/current/amd64/hvm/ebs-gp2/ami-id"
}
variable "path_to_file_key" {
  type    = string
  default = "~/.ssh/id_rsa.pub"
}