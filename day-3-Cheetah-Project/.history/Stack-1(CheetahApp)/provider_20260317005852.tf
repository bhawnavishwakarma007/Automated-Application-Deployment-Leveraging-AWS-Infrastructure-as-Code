provider "aws" {
  region = "us-east-1"

  # assume_role {
  #   role_arn = "arn:aws:iam::851725445607:role/tf-role"
  #   session_name = "tf-app-session"
  # }
  
}

terraform {
  required_version = "1.14.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.34.0"
    }
  }
  backend "s3" {
    bucket       = "dev-cara-app-s3-bucket"
    key          = "envs/dev/app/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}