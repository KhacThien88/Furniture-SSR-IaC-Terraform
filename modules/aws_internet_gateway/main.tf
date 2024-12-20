resource "aws_internet_gateway" "igw-master" {
  vpc_id   = var.id_vpc

  tags = {
    Name = var.tag
  }
}