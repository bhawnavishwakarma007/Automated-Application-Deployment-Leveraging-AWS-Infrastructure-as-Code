resource "aws_security_group" "be_asg_sg" {
  name        = "cheetah-${var.env_name}-be-asg-sg"
  description = "Security group for BE ASG."
  vpc_id      = var.vpc_id
}
resource "aws_security_group_ingress_rule" "" {
  
}