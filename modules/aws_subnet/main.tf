resource "aws_subnet" "subnet_master_1" {
  availability_zone = var.az
  vpc_id            = var.vpc_id
  cidr_block        = var.cidr_block_subnet

  tags = {
    Name = var.tag
  }
}