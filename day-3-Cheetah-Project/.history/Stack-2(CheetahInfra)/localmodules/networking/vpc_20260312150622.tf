resource "aws_vpc" "cheetah_infra_vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "cheetah-${var.env_name}-vpc"
  }
}