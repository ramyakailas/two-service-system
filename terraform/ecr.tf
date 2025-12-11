# ECR Repository for Service 1
resource "aws_ecr_repository" "service1" {
  name                 = "${var.project_name}/service1"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.project_name}-service1-ecr"
  }
}

# ECR Repository for Service 2
resource "aws_ecr_repository" "service2" {
  name                 = "${var.project_name}/service2"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.project_name}-service2-ecr"
  }
}

