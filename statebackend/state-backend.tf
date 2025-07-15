provider "aws" {
  region = "eu-west-1"
}

# S3 Bucket for Terraform State Storage
resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state-webapp-301"
}

resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_acl" "example" {
  depends_on = [
    aws_s3_bucket_ownership_controls.example,
    aws_s3_bucket_public_access_block.example,
  ]

  bucket = aws_s3_bucket.terraform_state.id
  acl    = "private"
}
# DynamoDB Table for Terraform State Locking
resource "aws_dynamodb_table" "terraform_state_lock" {
  name         = "terraform-state-lock-webapp-302" # Ensure this is unique
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
