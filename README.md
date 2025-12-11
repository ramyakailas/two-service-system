# Two-Service Architecture System

A simple, working architecture composed of two Python services that communicate with each other, with data stored in PostgreSQL.

## Architecture Overview

```
┌─────────────┐         ┌─────────────┐         ┌─────────────┐
│   Client    │────────▶│  Service 1  │────────▶│  Service 2  │
│             │         │  (API)      │         │  (Database) │
└─────────────┘         └─────────────┘         └──────┬──────┘
                                                        │
                                                        ▼
                                                ┌─────────────┐
                                                │ PostgreSQL  │
                                                │  Database   │
                                                └─────────────┘
```

### Components

1. **Service 1 (API Service)**: FastAPI service that exposes an endpoint `/api/string` which retrieves data from Service 2
2. **Service 2 (Database Service)**: FastAPI service that queries PostgreSQL and returns the stored string
3. **PostgreSQL**: Database containing seeded string data

## Quick Start

### Prerequisites

- Docker and Docker Compose installed
- (Optional) `curl` or `httpie` for testing

### Local Deployment (Docker Compose)

1. **Start all services:**
   ```bash
   docker-compose up -d
   ```

2. **Wait for services to be healthy** (about 10-15 seconds):
   ```bash
   docker-compose ps
   ```

3. **Verify the setup:**
   ```bash
   # Test Service 1 endpoint
   curl http://localhost:8000/api/string
   
   # Expected response:
   # {"string":"Hello from PostgreSQL! This is the seeded string."}
   ```

### Manual Verification Steps

1. **Check Service 1 health:**
   ```bash
   curl http://localhost:8000/
   ```

2. **Check Service 2 health:**
   ```bash
   curl http://localhost:8001/
   ```

3. **Test the full flow:**
   ```bash
   curl http://localhost:8000/api/string
   ```

4. **View logs:**
   ```bash
   docker-compose logs -f
   ```

### Stopping the System

```bash
docker-compose down
```

To remove volumes (including database data):
```bash
docker-compose down -v
```

## Service Details

### Service 1 (Port 8000)
- **Endpoint**: `GET /api/string`
- **Function**: Retrieves string from Service 2
- **Dependencies**: Service 2

### Service 2 (Port 8001)
- **Endpoint**: `GET /string`
- **Function**: Queries PostgreSQL and returns the latest message
- **Dependencies**: PostgreSQL

### PostgreSQL (Port 5432)
- **Database**: `mydb`
- **User**: `postgres`
- **Password**: `postgres`
- **Schema**: `messages` table with seeded data

## Local Development (Without Docker)

### Setup

1. **Start PostgreSQL:**
   ```bash
   # Using Docker
   docker run -d --name postgres-dev \
     -e POSTGRES_PASSWORD=postgres \
     -e POSTGRES_DB=mydb \
     -p 5432:5432 \
     -v $(pwd)/init-db.sql:/docker-entrypoint-initdb.d/init-db.sql \
     postgres:15-alpine
   ```

2. **Install dependencies:**
   ```bash
   cd service2
   pip install -r requirements.txt
   python app.py  # Runs on port 8001
   
   # In another terminal
   cd service1
   pip install -r requirements.txt
   export SERVICE2_URL=http://localhost:8001
   python app.py  # Runs on port 8000
   ```

## Troubleshooting

- **Service 1 returns 503**: Check if Service 2 is running and healthy
- **Service 2 returns 503**: Check if PostgreSQL is running and accessible
- **Connection refused**: Ensure all services are started and ports are not in use
- **Database errors**: Check PostgreSQL logs with `docker-compose logs postgres`

## AWS Deployment (Terraform)

For production deployment to AWS, see the [terraform/](terraform/) directory.

### Quick Start with Terraform

1. **Navigate to terraform directory:**
   ```bash
   cd terraform
   ```

2. **Configure variables:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your settings
   ```

3. **Deploy:**
   ```bash
   ./deploy.sh
   # or manually: terraform init && terraform apply
   ```

4. **Build and push Docker images:**
   See `terraform/README.md` for detailed instructions.

See [terraform/README.md](terraform/README.md) for complete Terraform deployment documentation.

## Architecture Evolution

See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed discussion on:
- Security boundaries
- Scaling strategies
- Networking considerations
- Deployment automation
- Observability

## Evolution Strategies

I can talk about the evolution strategies during the architecture review of this, in the call.