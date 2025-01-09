data "aws_route53_zone" "dns" {
  name     = var.dns-name
}
data "aws_route53_zone" "dns_2" {
  name     = var.dns-name
}
resource "aws_acm_certificate" "aws-ssl-cert" {
  domain_name       = join(".", [var.site-name, data.aws_route53_zone.dns.name])
  validation_method = "DNS"
  tags = {
    Name = "Webservers-ACM"
  }
}
resource "aws_acm_certificate" "aws-ssl-cert-2" {
  domain_name       = join(".", [var.site-name-2, data.aws_route53_zone.dns_2.name])
  validation_method = "DNS"
  tags = {
    Name = "Webservers-ACM"
  }
}
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for val in aws_acm_certificate.aws-ssl-cert.domain_validation_options : val.domain_name => {
      name   = val.resource_record_name
      record = val.resource_record_value
      type   = val.resource_record_type
    }
  }
  name    = each.value.name
  records = [each.value.record]
  ttl     = 60
  type    = each.value.type
  zone_id = data.aws_route53_zone.dns.zone_id
}
resource "aws_route53_record" "cert_validation_2" {
  for_each = {
    for val in aws_acm_certificate.aws-ssl-cert-2.domain_validation_options : val.domain_name => {
      name   = val.resource_record_name
      record = val.resource_record_value
      type   = val.resource_record_type
    }
  }
  name    = each.value.name
  records = [each.value.record]
  ttl     = 60
  type    = each.value.type
  zone_id = data.aws_route53_zone.dns_2.zone_id
}
resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.aws-ssl-cert.arn
  for_each                = aws_route53_record.cert_validation
  validation_record_fqdns = [aws_route53_record.cert_validation[each.key].fqdn]
}
resource "aws_acm_certificate_validation" "cert-2" {
  certificate_arn         = aws_acm_certificate.aws-ssl-cert-2.arn
  for_each                = aws_route53_record.cert_validation_2
  validation_record_fqdns = [aws_route53_record.cert_validation_2[each.key].fqdn]
}
resource "aws_route53_record" "app_alias" {
  zone_id = data.aws_route53_zone.dns.zone_id
  name    = join(".", [var.site-name, data.aws_route53_zone.dns.name])
  type    = "A"

  alias {
    name                   = var.lb_dns_name
    zone_id                = var.lb_zone_id
    evaluate_target_health = false
  }
}
resource "aws_route53_record" "app_alias_2" {
  zone_id = data.aws_route53_zone.dns.zone_id
  name    = join(".", [var.site-name-2, data.aws_route53_zone.dns_2.name])
  type    = "A"

  alias {
    name                   = var.lb_dns_name_2
    zone_id                = var.lb_zone_id_2
    evaluate_target_health = false
  }
}

