resource "aws_instance" "ec2_instance" {
  count         = var.number_of_instance
  ami           = data.aws_ami.linux.id
  instance_type = var.instance_type

  tags = {
    Name = "MyEC2Instance"
  }
  
}