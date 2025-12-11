# Helm Chart for Two-Service System

## Prerequisites

1. EKS cluster deployed via Terraform
2. kubectl configured for the cluster
3. AWS Load Balancer Controller installed
4. Docker images pushed to ECR

## Install

```bash
# Get values from Terraform
cd ../terraform
SERVICE1_REPO=$(terraform output -raw ecr_service1_repository_url)
SERVICE2_REPO=$(terraform output -raw ecr_service2_repository_url)
DB_HOST=$(terraform output -raw rds_address)
NAMESPACE=$(terraform output -raw namespace)

# Install the chart
cd ../helm
helm install two-service-system ./two-service-system \
  --namespace $NAMESPACE --create-namespace \
  --set service1.image.repository=$SERVICE1_REPO \
  --set service2.image.repository=$SERVICE2_REPO \
  --set database.host=$DB_HOST \
  --set database.password=<YOUR_DB_PASSWORD>
```

## Upgrade

```bash
helm upgrade two-service-system ./two-service-system \
  --namespace $NAMESPACE \
  --reuse-values
```

## Uninstall

```bash
helm uninstall two-service-system --namespace $NAMESPACE
```

## Configuration

See `values.yaml` for all configurable options.

| Parameter | Description | Default |
|-----------|-------------|---------|
| `service1.replicas` | Number of service1 replicas | `1` |
| `service1.image.repository` | ECR repository URL | `""` |
| `service2.replicas` | Number of service2 replicas | `1` |
| `service2.image.repository` | ECR repository URL | `""` |
| `database.host` | RDS endpoint | `""` |
| `database.password` | Database password | `""` |
| `ingress.enabled` | Enable ingress | `true` |

