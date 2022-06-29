terraform {
  backend "s3" {
    bucket  = "stackbucketniyiterraform"
    key     = "clixx-ecs-terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
    #dynamodb_table="clixx-statelock-tf"
  }
}