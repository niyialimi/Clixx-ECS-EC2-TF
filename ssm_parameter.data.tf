data "aws_secretsmanager_secret_version" "dev_creds" {
  secret_id = "dev_tf_cedentials"
}

locals {
  dev_tf_cedentials = jsondecode(
    data.aws_secretsmanager_secret_version.dev_creds.secret_string
  )
}