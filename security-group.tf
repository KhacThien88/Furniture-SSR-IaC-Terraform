
module "sg-instances-master" {
  source = "./modules/aws_security_group_instance"
  providers = {
    aws = aws.region-master
  }
  external_ip = var.external_ip
  sg_lb_id    = module.sg-instances-lb.id
  vpc_id      = module.vpc_master.id_vpc
  subnet_1    = var.cidr_block_worker_subnet_1
  depends_on = [ module.vpc_master ]
}
module "sg-instances-worker" {
  source = "./modules/aws_sg_worker"
  providers = {
    aws = aws.region-worker
  }
  external_ip = var.external_ip
  vpc_worker_id = module.vpc_worker.id_vpc
  depends_on = [ module.vpc_worker ]
}
module "sg-instances-lb" {
  source = "./modules/aws_security_group_lb"
  providers = {
    aws = aws.region-master
  }
  vpc_master_id = module.vpc_master.id_vpc
  depends_on = [ module.vpc_master ]
  master_sg_id = module.sg-instances-master.id
}