locals {
  domain_count = length(var.domains)
}

#
# Look up all SSL certificates in AWS Certificate Manager for all domains supported by the Application Load Balancer.
#
data "aws_acm_certificate" "ssl" {
  count       = local.domain_count
  domain      = var.domains[count.index]
  most_recent = true
  types       = ["AMAZON_ISSUED"]
}

#
# Create the port 443 listener for the Application Load Balancer.
#
resource "aws_lb_listener" "listener_443" {
  certificate_arn   = element(data.aws_acm_certificate.ssl.*.arn, 0)
  load_balancer_arn = var.alb_arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  # By default, all port 443 traffic will be routed to the target group.
  default_action {
    target_group_arn = var.tg_arn
    type             = "forward"
  }
}

#
# Add all SSL certificates to the port 443 listener.
#
resource "aws_lb_listener_certificate" "listener-certificate" {
  count           = local.domain_count
  certificate_arn = element(data.aws_acm_certificate.ssl.*.arn, count.index)
  listener_arn    = aws_lb_listener.listener_443.arn
}
