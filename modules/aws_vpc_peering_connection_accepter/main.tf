resource "aws_vpc_peering_connection_accepter" "accept_peering" {
  vpc_peering_connection_id = var.id_vpc_peering_connection
  auto_accept               = true
}