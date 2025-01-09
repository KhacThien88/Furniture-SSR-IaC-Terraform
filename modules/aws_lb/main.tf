resource "aws_lb" "application-lb" {
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.lb-sg-id]
  subnets            = [var.subnet_master_1_id,var.subnet_master_2_id]
}
