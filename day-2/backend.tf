terraform {
  backend "s3" {
    bucket       = "how-to-train-ur-dragonn"
    key          = "environments/dev/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

# resource "aws_s3_bucket" "tf-bucket" {
#   bucket = "how-to-train-ur-dragon"

#   versioning {
#     enabled = true
#   }
# }
