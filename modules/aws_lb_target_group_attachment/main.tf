resource "aws_lb_target_group_attachment" "apache1-attach" {
  target_group_arn = var.alb-tg-arn
  target_id        = var.master-instance-id
  port             = 80
}