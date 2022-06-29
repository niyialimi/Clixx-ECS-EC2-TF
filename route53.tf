resource "aws_route53_record" "clixx-app" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "dev.clixx-niyialimi.com"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_lb.clixx-ALB-ECS-tf.dns_name]
}