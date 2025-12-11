# Terraform Deployment for Two-Service System

This directory contains Terraform infrastructure as code (IaC) to deploy the two-service system to AWS.

## Architecture

The Terraform configuration deploys:

- **VPC** with public and private subnets across 2 availability zones
- **RDS PostgreSQL** database in private subnets
- **EKS (Elastic Kubernetes Service)** cluster with managed node groups
- **Kubernetes Deployments and Services** for both services
- **Kubernetes Ingress** with AWS Load Balancer Controller (creates ALB automatically)
- **ECR** repositories for container images
- **CloudWatch** for logging and monitoring
- **Kubernetes Service Discovery** (built-in DNS-based service discovery)

## Prerequisites

1. **AWS CLI** configured with appropriate credentials
2. **Terraform** >= 1.0 installed
3. **Docker** installed (for building and pushing images)
4. **AWS Account** with appropriate permissions

### Required AWS Permissions

- VPC creation and management
- EC2 (for VPC, subnets, security groups, EKS node groups)
- RDS (for PostgreSQL instance)
- EKS (for cluster, node groups)
- ECR (for container repositories)
- IAM (for roles and policies)
- CloudWatch (for log groups)
- Application Load Balancer (created by AWS Load Balancer Controller)

## Setup

1. **Copy the example variables file:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Edit `terraform.tfvars`** with your configuration:
   ```hcl
   aws_region  = "us-west-2"
   environment = "dev"
   db_password = "your-secure-password-here"
   ```

3. **Initialize Terraform:**
   ```bash
   terraform init
   ```

4. **Review the deployment plan:**
   ```bash
   terraform plan
   ```

5. **Apply the configuration:**
   ```bash
   terraform apply
   ```

## Building and Pushing Docker Images

After the infrastructure is created, you need to build and push the Docker images:

1. **Authenticate Docker to ECR:**
   ```bash
   aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin $(terraform output -raw ecr_service1_repository_url | cut -d'/' -f1)
   ```

2. **Build and push Service 1:**
   ```bash
   cd ../service1
   docker build -t service1 .
   docker tag service1:latest $(cd ../terraform && terraform output -raw ecr_service1_repository_url):latest
   docker push $(cd ../terraform && terraform output -raw ecr_service1_repository_url):latest
   ```

3. **Build and push Service 2:**
   ```bash
   cd ../service2
   docker build -t service2 .
   docker tag service2:latest $(cd ../terraform && terraform output -raw ecr_service2_repository_url):latest
   docker push $(cd ../terraform && terraform output -raw ecr_service2_repository_url):latest
   ```

4. **Restart Kubernetes deployments to pull new images:**
   ```bash
   kubectl rollout restart deployment/service1 -n $(terraform output -raw namespace)
   kubectl rollout restart deployment/service2 -n $(terraform output -raw namespace)
   ```

## Database Initialization

After RDS is created, you need to initialize the database schema:

1. **Get RDS endpoint:**
   ```bash
   terraform output rds_endpoint
   ```

2. **Connect to RDS and run init script:**
   ```bash
   PGPASSWORD=$(terraform output -raw db_password) psql -h $(terraform output -raw rds_address) -U postgres -d mydb -f ../init-db.sql
   ```

   Or use a bastion host or AWS Systems Manager Session Manager if RDS is not publicly accessible.

## Installing AWS Load Balancer Controller

Before accessing the services, you need to install the AWS Load Balancer Controller in your EKS cluster:

1. **Configure kubectl:**
   ```bash
   aws eks update-kubeconfig --region $(terraform output -raw region) --name $(terraform output -raw eks_cluster_name)
   ```

2. **Install AWS Load Balancer Controller using Helm:**
   ```bash
   helm repo add eks https://aws.github.io/eks-charts
   helm repo update
   helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
     -n kube-system \
     --set clusterName=$(terraform output -raw eks_cluster_name) \
     --set serviceAccount.create=false \
     --set serviceAccount.name=aws-load-balancer-controller
   ```

   Or follow the [official installation guide](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.7/deploy/installation/).

## Accessing the Services

After the AWS Load Balancer Controller creates the ALB, get the service URL:

```bash
kubectl get ingress -n $(terraform output -raw namespace) -o jsonpath='{.items[0].status.loadBalancer.ingress[0].hostname}'
```

Test the endpoint:
```bash
curl http://$(kubectl get ingress -n $(terraform output -raw namespace) -o jsonpath='{.items[0].status.loadBalancer.ingress[0].hostname}')/api/string
```

## Monitoring

- **CloudWatch Logs**: View EKS cluster logs in CloudWatch
- **Kubernetes Dashboard**: Use `kubectl` to monitor pod health and status
- **RDS Console**: Monitor database performance and metrics
- **EKS Console**: Monitor cluster and node group health

## Scaling

### Scaling Services

To scale services, update the desired count in `terraform.tfvars`:

```hcl
service1_desired_count = 3
service2_desired_count = 2
```

Then apply:
```bash
terraform apply
```

Or scale directly using kubectl:
```bash
kubectl scale deployment/service1 -n $(terraform output -raw namespace) --replicas=3
kubectl scale deployment/service2 -n $(terraform output -raw namespace) --replicas=2
```

### Scaling Node Group

To scale the EKS node group, update the variables:

```hcl
eks_node_min_size     = 1
eks_node_max_size     = 5
eks_node_desired_size = 3
```

Then apply:
```bash
terraform apply
```

## Cost Considerations

This setup includes:
- **RDS**: db.t3.micro instance (~$15/month)
- **EKS Cluster**: Control plane (~$73/month)
- **EKS Node Group**: 2x t3.medium instances (~$60/month)
- **ALB**: Application Load Balancer (~$16/month, created by ALB Controller)
- **NAT Gateways**: 2 NAT gateways (~$65/month)
- **Data Transfer**: Varies based on usage

**Estimated monthly cost**: ~$230-250/month for dev environment

To reduce costs:
- Use smaller instance types (e.g., t3.small for nodes)
- Use single NAT gateway (less HA)
- Use t3.small RDS with burstable performance
- Reduce node group size when not in use
- Consider using Fargate for EKS (pay per pod) instead of node groups

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

**Note**: This will delete all resources including the RDS database. Make sure to backup any important data first.

## Troubleshooting

### Services not starting
- Check pod logs: `kubectl logs -n <namespace> <pod-name>`
- Check pod status: `kubectl get pods -n <namespace>`
- Verify ECR images are pushed correctly
- Check security group rules for EKS nodes
- Verify Kubernetes secrets are created: `kubectl get secrets -n <namespace>`

### Database connection issues
- Verify RDS security group allows connections from EKS nodes security group
- Check RDS endpoint is correct in Kubernetes secret
- Verify database credentials in secret
- Test connection from a pod: `kubectl exec -it <pod-name> -n <namespace> -- psql -h <rds-endpoint> -U postgres`

### ALB/Ingress not working
- Verify AWS Load Balancer Controller is installed and running
- Check ingress status: `kubectl get ingress -n <namespace>`
- Verify service is running: `kubectl get svc -n <namespace>`
- Check security group rules for ALB
- Verify IAM permissions for Load Balancer Controller

### Cluster access issues
- Verify kubectl is configured: `kubectl cluster-info`
- Check IAM permissions for EKS cluster access
- Verify AWS CLI credentials are configured correctly

## Variables Reference

See `variables.tf` for all available variables and their descriptions.

## Outputs

After deployment, view all outputs:

```bash
terraform output
```

Key outputs:
- `eks_cluster_name`: EKS cluster name
- `eks_cluster_endpoint`: EKS control plane endpoint
- `kubectl_config_command`: Command to configure kubectl
- `rds_endpoint`: RDS database endpoint
- `ecr_service1_repository_url`: ECR repository URL for Service 1
- `ecr_service2_repository_url`: ECR repository URL for Service 2
- `namespace`: Kubernetes namespace for the services

