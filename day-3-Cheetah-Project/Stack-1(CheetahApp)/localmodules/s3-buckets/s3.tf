resource "aws_s3_bucket" "cara_fe_bucket" {
  bucket = "cara-${var.env_name}-fe-bucket"
}
resource "aws_s3_bucket" "cara_be_bucket" {
  bucket = "cara-${var.env_name}-be-bucket"
}