resource "aws_lambda_function" "etl_function" {
  function_name = "prosper-etl-lambda"
  role          = aws_iam_role.lambda_exec_role.arn
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.lambda_ecr_repo.repository_url}:latest"  # Use lambda_ecr_repo from ecr.tf
  source_code_hash = filebase64sha256("${path.module}/../lambda_functions/functions.py")
  timeout       = 60
  memory_size   = 512
    environment {
        variables = {
        S3_BUCKET_NAME = "prosper-etl-bucket" 
        }
    }
}

