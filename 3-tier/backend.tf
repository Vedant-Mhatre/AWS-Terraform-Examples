resource "aws_s3_bucket" "b" {
  bucket = "3tier-bucket"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Terraform   = "true"
    Environment = "Dev"
  }
}

resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name         = "tf-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockId"

  attribute {
    name = "LockId"
    type = "S"
  }

  tags = {
    Terraform   = "true"
    Environment = "Dev"
  }

}