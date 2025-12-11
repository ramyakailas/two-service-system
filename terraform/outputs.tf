output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "rds_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = aws_db_instance.postgres.endpoint
}

output "rds_address" {
  description = "RDS PostgreSQL address"
  value       = aws_db_instance.postgres.address
}

output "rds_port" {
  description = "RDS PostgreSQL port"
  value       = aws_db_instance.postgres.port
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.main.name
}

output "eks_cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.main.endpoint
}

output "eks_cluster_version" {
  description = "Kubernetes version of the EKS cluster"
  value       = aws_eks_cluster.main.version
}

output "kubectl_config_command" {
  description = "Command to configure kubectl for the EKS cluster"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.main.name}"
}

output "helm_install_command" {
  description = "Command to install the Helm chart"
  value       = <<-EOT
    helm install two-service-system ../helm/two-service-system \
      --namespace ${var.project_name} --create-namespace \
      --set service1.image.repository=${aws_ecr_repository.service1.repository_url} \
      --set service2.image.repository=${aws_ecr_repository.service2.repository_url} \
      --set database.host=${aws_db_instance.postgres.address} \
      --set database.password=<YOUR_DB_PASSWORD>
  EOT
}

output "ecr_service1_repository_url" {
  description = "ECR repository URL for Service 1"
  value       = aws_ecr_repository.service1.repository_url
}

output "ecr_service2_repository_url" {
  description = "ECR repository URL for Service 2"
  value       = aws_ecr_repository.service2.repository_url
}

output "region" {
  description = "AWS region"
  value       = var.aws_region
}

output "namespace" {
  description = "Kubernetes namespace for the application"
  value       = var.project_name
}

output "deployment_summary" {
  description = "Summary of deployed resources"
  value = {
    environment          = var.environment
    region               = var.aws_region
    vpc_id               = aws_vpc.main.id
    eks_cluster_name     = aws_eks_cluster.main.name
    eks_cluster_endpoint = aws_eks_cluster.main.endpoint
    eks_cluster_version  = aws_eks_cluster.main.version
    rds_endpoint         = aws_db_instance.postgres.endpoint
    ecr_service1_url     = aws_ecr_repository.service1.repository_url
    ecr_service2_url     = aws_ecr_repository.service2.repository_url
    namespace            = var.project_name
  }
}

