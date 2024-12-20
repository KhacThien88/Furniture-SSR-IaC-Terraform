resource "aws_vpc_peering_connection" "connect" {
  peer_vpc_id = var.id_vpc_worker
  vpc_id      = var.id_vpc_master
  peer_region = var.region-worker
}