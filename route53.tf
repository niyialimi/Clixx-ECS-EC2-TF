resource "aws_route53_record" "clixx-app" {
  zone_id = var.zone_id
  name    = "ecs.dev.clixx-niyialimi.com"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_lb.clixx-ALB-ECS-tf.dns_name]
}

# resource "aws_route53_record" "clixx-app" {
#   zone_id = var.zone_id
#   name    = "ecs.dev.clixx-niyialimi.com"
#   type    = "A"
#   ttl     = "300"

#   alias {
#     evaluate_target_health = false
#     name                   = aws_lb.clixx-ALB-ECS-tf.dns_name
#     #zone_id                = aws_lb.example.zone_id
#   }
# }


# resource "aws_route53_record" "dub" {
#   zone_id = "Z18WO5VD3QY05U"
#   name    = "dub.isochron.us"
#   type    = "CNAME"
#   ttl     = "6"
#   records = ["cname.backplane.io"]
# }