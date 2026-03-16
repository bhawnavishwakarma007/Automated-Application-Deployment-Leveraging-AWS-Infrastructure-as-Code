########################
# Networking
########################
variable "vpc_cidr" {
  type        = string
  description = "Vpc cidr."
}

variable "env_name" {
  type        = string
  description = "Environment name."
}

variable "public_subnet_count" {
  type        = number
  description = "Number of public subnets."
}

variable "private_subnet_count" {
  type = number
  description = "Number of private subnets."
}

variable "rds_sg_ingress_rules" {
  type = map(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = {}
}

variable "rds_db_username" {
  type        = string
  description = "RDS DB Username."
}

variable "rds_db_parameter_name" {
  type        = string
  description = "RDS Parameter name for password."
}