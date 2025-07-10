# outputs.tf

output "s3_bucket_name" {
  value = aws_s3_bucket.etl_bucket.bucket
}
output "s3_bucket_arn" {
  value = aws_s3_bucket.etl_bucket.arn
}
output "s3_bucket_versioning_status" {
  description = "The versioning status of the ETL S3 bucket."
  value       = aws_s3_bucket.etl_bucket.versioning[0].status
}
output "s3_bucket_encryption" {
  description = "The SSE algorithm used for the ETL S3 bucket."
  value       = one(aws_s3_bucket_server_side_encryption_configuration.sse_config.rule[*].apply_server_side_encryption_by_default[0].sse_algorithm)
}