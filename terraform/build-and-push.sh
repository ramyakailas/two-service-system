#!/bin/bash
#
# Build and push Docker images to ECR
#
# Usage: ./build-and-push.sh
#

set -e

cd "$(dirname "$0")"
PROJECT_ROOT="$(cd .. && pwd)"

# Get configuration from Terraform
SERVICE1_REPO=$(terraform output -raw ecr_service1_repository_url)
SERVICE2_REPO=$(terraform output -raw ecr_service2_repository_url)
AWS_REGION=$(terraform output -raw region 2>/dev/null || echo "us-west-2")
ECR_REGISTRY=$(echo "$SERVICE1_REPO" | cut -d'/' -f1)

echo "Building and pushing images to ECR..."
echo "  Region: $AWS_REGION"
echo "  Registry: $ECR_REGISTRY"

# Login to ECR
aws ecr get-login-password --region "$AWS_REGION" | \
  docker login --username AWS --password-stdin "$ECR_REGISTRY"

# Build and push Service 1
echo "Building service1..."
docker build -t "$SERVICE1_REPO:latest" "$PROJECT_ROOT/service1"
docker push "$SERVICE1_REPO:latest"

# Build and push Service 2
echo "Building service2..."
docker build -t "$SERVICE2_REPO:latest" "$PROJECT_ROOT/service2"
docker push "$SERVICE2_REPO:latest"

echo "Done! Restart deployments to use new images:"
echo "  kubectl rollout restart deployment/service1 deployment/service2 -n \$(terraform output -raw namespace)"
