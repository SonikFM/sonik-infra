#!/bin/bash
# deploy-cognee-stack.sh
# Deploy Cognee infrastructure (connects to your existing PostgreSQL)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKER_DIR="$SCRIPT_DIR/../docker"

echo "=========================================="
echo "Sonik Cognee Stack Deployment"
echo "=========================================="

# Check for .env file
if [ ! -f "$DOCKER_DIR/.env" ]; then
    echo "ERROR: .env file not found!"
    echo ""
    echo "1. Copy the template:"
    echo "   cp $DOCKER_DIR/.env.cognee-stack $DOCKER_DIR/.env"
    echo ""
    echo "2. Fill in YOUR PostgreSQL connection details"
    echo ""
    exit 1
fi

cd "$DOCKER_DIR"

# Pull latest images
echo ""
echo "[1/3] Pulling latest images..."
docker-compose -f docker-compose.cognee-stack.yaml pull

# Start services
echo ""
echo "[2/3] Starting services..."
docker-compose -f docker-compose.cognee-stack.yaml up -d

# Wait and show status
echo ""
echo "[3/3] Waiting for services..."
sleep 10

echo ""
echo "=========================================="
echo "Deployment Complete!"
echo "=========================================="
echo ""
echo "Services:"
echo "  FalkorDB:       localhost:6379  (graph database)"
echo "  RedisVL:        localhost:6380  (semantic cache)"
echo "  RedisInsight:   http://localhost:8001"
echo "  Cognee API:     http://localhost:8000"
echo "  NocoDB:         http://localhost:8080"
echo "  Grist:          http://localhost:8484"
echo ""
echo "PostgreSQL: Using YOUR external database (configured in .env)"
echo ""
docker-compose -f docker-compose.cognee-stack.yaml ps
