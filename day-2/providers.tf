provider "aws" {
  region = "us-east-1"

  # assume_role {
  #   role_arn = "arn:aws:iam::868713841842:role/tf-role"
  #   session_name = "tf-access"
  # }
}

# terraform {
#   required_version = "1.14.3"
#   required_providers {
#     aws = {
#       version = "~>6.0.0"
#       source = "hashicorp/aws"
#     }
#   }
# }