# variable "AWS_ACCESS_KEY" {
#   sensitive = true
# }

# variable "AWS_SECRET_KEY" {
#   sensitive = true
# }

variable "AWS_REGION" {
  default = "us-east-1"
}

variable "availability_zones" {
  type = list(string)
  default = [
    "us-east-1a",
    "us-east-1b",
  ]
}
variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnets_cidr" {
  type = list(string)
  default = [
    "10.0.0.0/23",
    "10.0.2.0/23",
  ]
}

variable "private_subnets_server_cidr" {
  type = list(string)
  default = [
    "10.0.4.0/23",
    "10.0.6.0/23",
  ]
}

variable "private_subnets_rds_cidr" {
  type = list(string)
  default = [
    "10.0.8.0/22",
    "10.0.12.0/22",
  ]
}

variable "public_subnets_names" {
  type = list(string)
  default = [
    "Clixx-PublicSubA-Tf",
    "Clixx-PublicSubB-Tf",
  ]
}

variable "private_subnets_server_names" {
  type = list(string)
  default = [
    "Clixx-PrivateSubWebA-Tf",
    "Clixx-PrivateSubWebB-Tf",
  ]
}

variable "private_subnets_rds_names" {
  type = list(string)
  default = [
    "Clixx-PrivateSubRDSA-Tf",
    "Clixx-PrivateSubRDSB-Tf",
  ]
}

variable "PATH_TO_PRIVATE_KEY" {
  default = "stackkp"
}

variable "PATH_TO_PUBLIC_KEY" {
  default = "stackkp.pub"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "bastion_ami_id" {
  default = "ami-0a27c39dd548772e9"
}

variable "ecs_ami_id" {
  default = "ami-0d8fc00d1dec7e49b"
}

variable "cluster_name" {
  default = "Clixx-Cluster-Tf"
}

variable "repository_name" {
  default = "clixxvpc-repository"
}

variable "REPO_TAG" {
  default = "clixxvpc-img-tf"
}

variable "ami_id" {
  default = "ami-0022f774911c1d690"
}

