#!/bin/bash
set -e #prevent script from continuing on error

# Load env vars from .env file
source ../.env 

# Variables
ECR_REPO_NAME=$ECR_REPO_NAME
REGION=$AWS_REGION
ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)

# Login to ECR
aws ecr get-login-password --region $REGION | \
docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

# Build Docker image
docker build -t $ECR_REPO_NAME .

# Tag Docker image
docker tag $ECR_REPO_NAME:latest $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$ECR_REPO_NAME:latest

# Create ECR repo if it doesn't exist
aws ecr describe-repositories --repository-names $ECR_REPO_NAME --region $REGION >/dev/null 2>&1 || \
aws ecr create-repository --repository-name $ECR_REPO_NAME --region $REGION

# Push image to ECR
docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$ECR_REPO_NAME:latest

# Output success message
echo "Docker image pushed to ECR successfully!"
