variable "aws_region" {
  type        = string
  description = "AWS Region to deploy resources in"
}

variable "s3_bucket_name" {
  type        = string
  description = "Name of the S3 bucket"
}

variable "aws_access_key_id" {
  type        = string
  description = "AWS access key"
}

variable "aws_secret_access_key" {
  type        = string
  description = "AWS secret key"
}

variable "lambda_image_repo_name" {
  type        = string
  description = "ECR repo name for the Lambda image"
}

variable "account_id" {
  type        = string
  description = "AWS Account ID"
}
