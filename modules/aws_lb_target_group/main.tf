resource "aws_lb_target_group" "app-lb-tg" {
  name        = "app-lb-tg"
  port        = 31000
  target_type = "instance"
  vpc_id      = var.vpc_master_id
  protocol    = "HTTP"
  health_check {
    enabled  = true
    interval = 10
    path     = "/index.html"
    port     = 80
    protocol = "HTTP"
    matcher  = "200-399"
  }
  tags = {
    Name = "webserver-target-group"
  }
}