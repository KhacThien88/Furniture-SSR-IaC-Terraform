resource "aws_route_table" "route-table-master" {
  vpc_id   = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.igw-id
  }

  route {
    cidr_block = var.cidr_valid
    gateway_id = var.vpc-peering-id
  }
  lifecycle {
    ignore_changes = all
  }
  tags = {
    Name = var.tag
  }
}