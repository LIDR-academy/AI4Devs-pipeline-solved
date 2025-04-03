# S3 bucket for resumes
resource "aws_s3_bucket" "lt_resumes_bucket" {
  bucket = "lt-recruiting-resumes-${random_string.bucket_suffix.result}"
  force_destroy = true

  tags = {
    Name = "LTI Resumes Bucket"
    app  = var.app_name
  }
}

# Generate random suffix for bucket name uniqueness
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# Block public access to the bucket
resource "aws_s3_bucket_public_access_block" "resumes_bucket_access" {
  bucket = aws_s3_bucket.lt_resumes_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Server-side encryption configuration
resource "aws_s3_bucket_server_side_encryption_configuration" "resumes_encryption" {
  bucket = aws_s3_bucket.lt_resumes_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Bucket lifecycle configuration for resumes
resource "aws_s3_bucket_lifecycle_configuration" "resumes_lifecycle" {
  bucket = aws_s3_bucket.lt_resumes_bucket.id

  rule {
    id     = "archive-old-resumes"
    status = "Enabled"

    transition {
      days          = 90
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 365
      storage_class = "GLACIER"
    }
  }
}

# CORS configuration for the bucket
resource "aws_s3_bucket_cors_configuration" "resumes_cors" {
  bucket = aws_s3_bucket.lt_resumes_bucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST", "DELETE"]
    allowed_origins = ["*"] # Restrict to your application domain in production
    max_age_seconds = 3000
  }
} 