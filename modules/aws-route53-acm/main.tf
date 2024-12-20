data "aws_route53_zone" "dns" {
  name     = var.dns-name
}
resource "aws_acm_certificate" "aws-ssl-cert" {
  domain_name       = join(".", [var.site-name, data.aws_route53_zone.dns.name])
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
resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.aws-ssl-cert.arn
  for_each                = aws_route53_record.cert_validation
  validation_record_fqdns = [aws_route53_record.cert_validation[each.key].fqdn]
}

