resource "aws_db_subnet_group" "private_sub_grp" {
  name       = "cheetah-${var.env_name}-subnet-grp"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "cheetah-${var.env_name}-subnet-grp"
  }
}