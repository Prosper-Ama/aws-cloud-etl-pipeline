# outputs.tf

output "s3_bucket_name" {
  value = aws_s3_bucket.etl_bucket.bucket
}
output "s3_bucket_arn" {
  value = aws_s3_bucket.etl_bucket.arn
}
output "s3_bucket_versioning_status" {
  value = aws_s3_bucket_versioning.etl_versioning.status
}
output "s3_bucket_encryption" {
  value = aws_s3_bucket_server_side_encryption_configuration.sse_config.rule[0].apply_server_side_encryption_by_default[0].sse_algorithm
}