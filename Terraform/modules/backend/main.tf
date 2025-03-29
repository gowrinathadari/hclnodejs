#create s3 bucket for remot bacend
resource "aws_s3_bucket" "my_bucket" {
    bucket = "terraform-backend-hcl-2023"
}


#create Dynamodb table
resource "aws_dynamodb_table" "terraform_lock" {
  name           = "terraform-lock"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S" #it is a string
  }
}