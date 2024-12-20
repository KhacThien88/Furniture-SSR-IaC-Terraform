module "route53-acm" {
  source = "./modules/aws-route53-acm"
  providers = {
    aws = aws.region-master
  }
  site-name = var.site-name
  dns-name = var.dns-name
}
