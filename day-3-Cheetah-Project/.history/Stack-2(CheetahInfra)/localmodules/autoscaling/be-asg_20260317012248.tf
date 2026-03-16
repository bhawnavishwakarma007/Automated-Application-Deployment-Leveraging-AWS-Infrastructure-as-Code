resource "aws_security_group" "be_asg_sg" {
  name = "cheetah-${var.env_name}-be-asg-sg"
  
}