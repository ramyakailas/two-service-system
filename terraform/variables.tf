variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "two-service-system"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# RDS Variables
variable "rds_engine_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "15.4"
}

variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_allocated_storage" {
  description = "RDS allocated storage in GB"
  type        = number
  default     = 20
}

variable "rds_backup_retention_period" {
  description = "RDS backup retention period in days"
  type        = number
  default     = 7
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "mydb"
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "postgres"
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}

# EKS Variables
variable "eks_cluster_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.28"
}

variable "eks_node_instance_type" {
  description = "EC2 instance type for EKS node group"
  type        = string
  default     = "t3.medium"
}

variable "eks_node_min_size" {
  description = "Minimum number of nodes in EKS node group"
  type        = number
  default     = 1
}

variable "eks_node_max_size" {
  description = "Maximum number of nodes in EKS node group"
  type        = number
  default     = 3
}

variable "eks_node_desired_size" {
  description = "Desired number of nodes in EKS node group"
  type        = number
  default     = 2
}

variable "eks_node_ssh_key" {
  description = "SSH key name for EKS node group (optional)"
  type        = string
  default     = null
}

# Service Variables
variable "service1_cpu" {
  description = "CPU units for Service 1 (in millicores, e.g., 256 = 0.25 CPU)"
  type        = number
  default     = 256
}

variable "service1_memory" {
  description = "Memory for Service 1 in MB"
  type        = number
  default     = 512
}

variable "service1_desired_count" {
  description = "Desired number of Service 1 replicas"
  type        = number
  default     = 1
}

variable "service2_cpu" {
  description = "CPU units for Service 2 (in millicores, e.g., 256 = 0.25 CPU)"
  type        = number
  default     = 256
}

variable "service2_memory" {
  description = "Memory for Service 2 in MB"
  type        = number
  default     = 512
}

variable "service2_desired_count" {
  description = "Desired number of Service 2 replicas"
  type        = number
  default     = 1
}

variable "log_retention_days" {
  description = "CloudWatch log retention period in days"
  type        = number
  default     = 14
}

variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default = {
    Owner      = "Platform Team"
    CostCenter = "Engineering"
    DataClass  = "Internal"
  }
}

