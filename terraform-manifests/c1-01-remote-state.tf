resource "aws_dynamodb_table" "terraform_locks" {
  name         = var.locks_table
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

module "s3_backend" {
  source  = "terraform-aws-modules/s3-bucket/aws"  # Terraform Registry Module
  bucket  = var.backend_bucket_name
  versioning = {
    enabled = true
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_kms_key" "mykey" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

