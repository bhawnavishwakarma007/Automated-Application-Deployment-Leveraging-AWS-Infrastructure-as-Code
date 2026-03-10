module "ec2_instance" {
  source             = "./localmodules/ec2"
  instance_type      = var.instance_type
  number_of_instance = var.number_of_instance
}