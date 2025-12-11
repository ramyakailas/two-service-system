#!/bin/bash

# Terraform deployment script for two-service system

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "🚀 Deploying two-service system to AWS with Terraform..."
echo ""

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "❌ Error: Terraform is not installed. Please install Terraform and try again."
    exit 1
fi

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "❌ Error: AWS CLI is not installed. Please install AWS CLI and try again."
    exit 1
fi

# Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    echo "⚠️  terraform.tfvars not found. Creating from example..."
    cp terraform.tfvars.example terraform.tfvars
    echo "📝 Please edit terraform.tfvars with your configuration, especially db_password!"
    echo ""
    read -p "Press Enter to continue after editing terraform.tfvars..."
fi

# Check if db_password is set
if grep -q "CHANGE_ME_SECURE_PASSWORD" terraform.tfvars 2>/dev/null; then
    echo "⚠️  Warning: db_password appears to be the default value. Please update it in terraform.tfvars"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Initialize Terraform
echo "📦 Initializing Terraform..."
terraform init

# Plan deployment
echo ""
echo "📋 Planning deployment..."
terraform plan -out=tfplan

# Ask for confirmation
echo ""
read -p "Apply this plan? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Deployment cancelled."
    rm -f tfplan
    exit 0
fi

# Apply deployment
echo ""
echo "🔨 Applying Terraform configuration..."
terraform apply tfplan
rm -f tfplan

# Get outputs
echo ""
echo "✅ Deployment complete!"
echo ""
echo "📋 Deployment Summary:"
echo "===================="
terraform output -json | jq -r '
  "EKS Cluster: " + .eks_cluster_name.value,
  "EKS Endpoint: " + .eks_cluster_endpoint.value,
  "RDS Endpoint: " + .rds_endpoint.value,
  "Namespace: " + .namespace.value,
  "",
  "Next Steps:",
  "1. Configure kubectl: " + .kubectl_config_command.value,
  "2. Install AWS Load Balancer Controller (see README.md)",
  "3. Build and push Docker images to ECR",
  "4. Initialize the database with init-db.sql",
  "5. Get ALB DNS: kubectl get ingress -n " + .namespace.value + " -o jsonpath='\''{.items[0].status.loadBalancer.ingress[0].hostname}'\''",
  "6. Test the service URL"
'

echo ""
echo "📚 See terraform/README.md for detailed instructions on building and pushing images."

