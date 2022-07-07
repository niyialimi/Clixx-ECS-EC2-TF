#==== Retrieve database snapshot ======#
data "aws_db_snapshot" "db_snapshot" {
  most_recent            = true
  db_snapshot_identifier = "arn:aws:rds:us-east-1:743650199199:snapshot:clixx-rds-tf-final-snapshot"
}

#==== Create Database Subnet Group ======#
resource "aws_db_subnet_group" "db_subnets" {
  name       = "clixx-rds-subnet-group-tf"
  subnet_ids = [aws_subnet.private_rds_subnet.*.id[0], aws_subnet.private_rds_subnet.*.id[1]]
  tags = {
    Name = "clixx-rds-subnet-group-tf"
  }
}

#==== Create RDS Instance ======#
resource "aws_db_instance" "rds_db_tf" {
  instance_class         = "db.m6g.large"
  identifier             = "clixx-rds-tf"
  db_subnet_group_name   = aws_db_subnet_group.db_subnets.id
  snapshot_identifier    = data.aws_db_snapshot.db_snapshot.id
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true
}
