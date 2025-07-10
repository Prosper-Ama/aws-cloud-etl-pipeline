# Lambda Execution Role
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Step Functions Role
resource "aws_iam_role" "step_fn_role" {
  name = "step_fn_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "states.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "step_fn_invoke_lambda" {
  name = "step_fn_invoke_lambda_policy"
  role = aws_iam_role.step_fn_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = "lambda:InvokeFunction",
      Resource = "arn:aws:lambda:ca-central-1:637423212398:function:prosper-etl-lambda"
    }]
  })
}
# IAM Policy for Lambda to access S3
resource "aws_iam_policy" "lambda_s3_access" {
  name        = "LambdaS3AccessPolicy"
  description = "Policy to allow Lambda function to access S3 bucket"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = "s3:*",
      Resource = "arn:aws:s3:::prosper-etl-bucket/*"
    }]
  })
}
resource "aws_iam_role_policy_attachment" "lambda_s3_access_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_s3_access.arn
}
# IAM Policy for Step Functions to access Lambda
resource "aws_iam_policy" "step_fn_lambda_access" {
  name        = "StepFnLambdaAccessPolicy"
  description = "Policy to allow Step Functions to invoke Lambda function"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = "lambda:InvokeFunction",
      Resource = "arn:aws:lambda:ca-central-1:637423212398:function:prosper-etl-lambda"
    }]
  })
}
resource "aws_iam_role_policy_attachment" "step_fn_lambda_access_attach" {
  role       = aws_iam_role.step_fn_role.name
  policy_arn = aws_iam_policy.step_fn_lambda_access.arn
}
# IAM Policy for Lambda to access ECR
resource "aws_iam_policy" "lambda_ecr_access" {
  name        = "LambdaECRAccessPolicy"
  description = "Policy to allow Lambda function to access ECR repository"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage"
      ],
      Resource = "arn:aws:ecr:ca-central-1:637423212398:repository/prosper-etl-lambda-fn"
    }]
  })
}
resource "aws_iam_role_policy_attachment" "lambda_ecr_access_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_ecr_access.arn
}
# IAM Policy for Step Functions to access ECR
resource "aws_iam_policy" "step_fn_ecr_access" {
  name        = "StepFnECRAccessPolicy"
  description = "Policy to allow Step Functions to access ECR repository"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage"
      ],
      Resource = "arn:aws:ecr:ca-central-1:637423212398:repository/prosper-etl-lambda-fn"
    }]
  })
}
resource "aws_iam_role_policy_attachment" "step_fn_ecr_access_attach" {
  role       = aws_iam_role.step_fn_role.name
  policy_arn = aws_iam_policy.step_fn_ecr_access.arn
}
# IAM Policy for Redshift to access S3
# provisioned online = arn:aws:iam::637423212398:role/RedshiftS3AccessRole

