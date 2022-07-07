data "aws_secretsmanager_secret_version" "test_creds" {
  secret_id = "test_tf_cedentials"
}

locals {
  test_tf_cedentials = jsondecode(
    data.aws_secretsmanager_secret_version.test_creds.secret_string
  )
}
