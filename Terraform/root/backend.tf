terraform {
  backend "s3" {
    bucket         = "terraform-backend-hcl-2023"
    key            = "gowrinath/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}