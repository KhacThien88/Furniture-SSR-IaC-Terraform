resource "aws_lb_target_group" "app-lb-tg" {
  port        = var.app_port
  target_type = "instance"
  vpc_id      = var.vpc_master_id
  protocol    = "HTTP"
  health_check {
    enabled  = true
    interval = 10
    path     = "/"
    port     = 80
    protocol = "HTTP"
    matcher  = "200-399"
  }
}