# resource "aws_route53_record" "clixx-app" {
#   zone_id = var.zone_id
#   name    = "ecs.uat.clixx-niyialimi.com"
#   type    = "CNAME"
#   ttl     = "300"
#   records = [aws_lb.clixx-ALB-ECS-tf.dns_name]
# }

data "aws_route53_zone" "clixx-app" {
  name         = "uat.clixx-niyialimi.com"
  private_zone = false
}

resource "aws_route53_record" "uat" {
  zone_id = data.aws_route53_zone.clixx-app.zone_id
  name    = "uat.clixx-niyialimi.com"
  type    = "A"

  alias {
    name                   = aws_lb.clixx-ALB-ECS-tf.dns_name
    zone_id                = aws_lb.clixx-ALB-ECS-tf.zone_id
    evaluate_target_health = true
  }
}
