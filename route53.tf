resource "aws_route53_record" "clixx-app" {
  zone_id = var.zone_id
  name    = "dev.clixx-niyialimi.com"
  type    = "A"
  ttl     = "300"
  records = [aws_lb.clixx-ALB-ECS-tf.dns_name]
}