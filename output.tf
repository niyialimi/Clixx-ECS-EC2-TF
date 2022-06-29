################################################################################
# Output the DNS Name of the ELB
################################################################################
output "elb_dns_name" {
  description = "DNS Name of the ELB:"
  value       = aws_lb.clixx-ALB-ECS-tf.dns_name
}

output "rds_endpoint" {
  value = data.aws_db_snapshot.db_snapshot.id
}