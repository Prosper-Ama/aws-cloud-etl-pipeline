resource "aws_s3_bucket" "etl_bucket" {
  bucket = var.s3_bucket_name

  tags = {
    Name        = "ETL S3 Bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_versioning" "etl_versioning" {
  bucket = aws_s3_bucket.etl_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sse_config" {
  bucket = aws_s3_bucket.etl_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
