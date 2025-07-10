# ecr.tf

resource "aws_ecr_repository" "lambda_ecr_repo" {
  name = "prosper-etl-lambda-fn"
}

# Output the repository URL for use in Lambda
output "lambda_ecr_repo_url" {
  value = aws_ecr_repository.lambda_ecr_repo.repository_url
  description = "ECR repository URL for Lambda function image"
}
