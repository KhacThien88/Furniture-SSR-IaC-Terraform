resource "aws_lb_listener" "lb-https-listener" {
  load_balancer_arn = var.alb-arn
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = var.acm-arn
  default_action {
    type             = "forward"
    target_group_arn = var.alb-target-group-arn
  }
}
resource "aws_lb_listener" "lb-http-listener" {
  load_balancer_arn = var.alb-arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}