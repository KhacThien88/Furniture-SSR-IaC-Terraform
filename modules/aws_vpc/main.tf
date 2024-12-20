resource "aws_vpc" "vpc_master" {
  cidr_block           = var.cidr_block_vpc
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.tag
  }
}