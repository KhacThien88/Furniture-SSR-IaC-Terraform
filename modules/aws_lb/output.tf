output "arn" {
  value = aws_lb.application-lb.arn
}
output "dns" {
  value = aws_lb.application-lb.dns_name
}
output "zone_id" {
  value = aws_lb.application-lb.zone_id
}