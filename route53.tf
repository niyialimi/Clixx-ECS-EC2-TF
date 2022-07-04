resource "aws_route53_record" "clixx-app" {
  zone_id = var.zone_id
  name    = "ecs.dev.clixx-niyialimi.com"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_lb.clixx-ALB-ECS-tf.dns_name]
}