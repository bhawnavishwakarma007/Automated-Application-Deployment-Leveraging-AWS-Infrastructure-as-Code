env_name             = "dev"
vpc_cidr             = "10.0.0.0/16"
public_subnet_count  = 3
private_subnet_count = 3
rds_sg_ingress_rules = {
  mysql = {
    description = "App MYSQL DB Connection"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
}
rds_db_username       = "admin"
rds_db_parameter_name = "rds_db_password"