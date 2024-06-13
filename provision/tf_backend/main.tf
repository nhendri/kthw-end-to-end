provider "aws" {}

variable s3_backend_name{
  description = "shell environment variable for s3 backend"
  type        = string
}

variable dynamodb_backend_lock_name{
  description = "shell environment variable for dynamodb lock table"
  type        = string
}

locals {
    kthw_tags = {
        project = "kthw-project"
    }
}

resource "aws_s3_bucket" "kthw_tf_backends_bucket" {
  bucket = var.s3_backend_name
  tags = {
    Project = local.kthw_tags.project
  }
}

resource "aws_s3_bucket_versioning" "kthw_tf_backends_versioning" {
  bucket = aws_s3_bucket.kthw_tf_backends_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "terraform_lock_table" {
  name           = var.dynamodb_backend_lock_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key       = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = {
    Project = local.kthw_tags.project
  }
}

output "bucket_name" {
  value = aws_s3_bucket.kthw_tf_backends_bucket.id
}

output "dynamo_db_name" {
  value = aws_dynamodb_table.terraform_lock_table.id
}
