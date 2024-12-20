module "lb" {
  source = "./modules/aws_lb"
  providers = {
    aws = aws.region-master
  }
  lb-sg-id = module.sg-instances-lb.id
  subnet_master_1_id = module.subnet_master_1.id
  subnet_master_2_id = module.subnet_master_2.id
}
module "lb-target-groups" {
  source = "./modules/aws_lb_target_group"
  providers = {
    aws = aws.region-master
  }
  vpc_master_id = module.vpc_master.id_vpc
}
module "lb-listener" {
  source = "./modules/aws_lb_listener"
  providers = {
    aws = aws.region-master
  }
  alb-arn = module.lb.arn
  alb-target-group-arn = module.lb-target-groups.arn
  acm-arn = module.route53-acm.arn
}
module "attach" {
  source = "./modules/aws_lb_target_group_attachment"
  providers = {
    aws = aws.region-master
  }
  alb-tg-arn = module.lb-target-groups.arn
  master-instance-id = module.master-control-plane.id
}