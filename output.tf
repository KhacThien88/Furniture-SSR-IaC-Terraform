output "vpc_master_id" {
  value = module.vpc_master.id_vpc
}
output "route_table_worker_id" {
  value = module.route-table-worker.id
}
output "route_table_association" {
  value = module.set-worker-default-router-associate.id
}
output "public_ip_master" {
  value = module.master-control-plane.public_ip
}
output "public_ip_worker" {
  value = module.worker.public_ip
}