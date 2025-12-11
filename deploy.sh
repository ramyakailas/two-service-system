#!/bin/bash

# Deployment script for two-service system

set -e

echo "Deploying two-service architecture system..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "Error: Docker is not running. Please start Docker and try again."
    exit 1
fi

# Check if Docker Compose is available
if ! command -v docker-compose &> /dev/null; then
    echo "Error: docker-compose is not installed. Please install it and try again."
    exit 1
fi

# Stop existing containers if any
echo "Stopping existing containers..."
docker-compose down 2>/dev/null || true

# Build and start services
echo "Building and starting services..."
docker-compose up -d --build

# Wait for services to be ready
echo "Waiting for services to be ready..."
sleep 5

# Check service health
max_attempts=30
attempt=0

while [ $attempt -lt $max_attempts ]; do
    if curl -f http://localhost:8000/api/string > /dev/null 2>&1; then
        echo "Service 1 is healthy"
        break
    fi
    attempt=$((attempt + 1))
    sleep 2
done

if [ $attempt -eq $max_attempts ]; then
    echo "Service 1 failed to become healthy"
    docker-compose logs
    exit 1
fi

# Verify the full flow
echo "Verifying system..."
response=$(curl -s http://localhost:8000/api/string)

if echo "$response" | grep -q "result"; then
    echo "System is working correctly!"
    echo "Response: $response"
else
    echo "System verification failed"
    echo "Response: $response"
    docker-compose logs
    exit 1
fi

echo ""
echo "Deployment successful!"
echo ""
echo "Service endpoints:"
echo "  - Service 1 (API): http://localhost:8000/api/string"
echo "  - Service 2 (Data): http://localhost:8001/api/message"
echo ""
echo "To view logs: docker-compose logs -f"
echo "To stop: docker-compose down"
