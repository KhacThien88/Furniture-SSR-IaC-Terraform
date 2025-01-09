module "route53-acm" {
  source = "./modules/aws-route53-acm"
  providers = {
    aws = aws.region-master
  }
  site-name = var.site-name[0]
  dns-name = var.dns-name
  lb_dns_name = module.lb.dns
  lb_zone_id = module.lb.zone_id
  site-name-2 = var.site-name[1]
  lb_dns_name_2 = module.lb-2.dns
  lb_zone_id_2 = module.lb-2.zone_id
}
