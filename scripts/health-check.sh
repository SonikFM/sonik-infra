#!/bin/bash
# health-check.sh
# Verify Cognee stack services

echo "Sonik Cognee Stack Health Check"
echo "================================"

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

check_tcp() {
    local name=$1
    local port=$2
    if nc -z localhost "$port" 2>/dev/null; then
        echo -e "  $name: ${GREEN}OK${NC} (port $port)"
    else
        echo -e "  $name: ${RED}FAIL${NC} (port $port)"
    fi
}

check_http() {
    local name=$1
    local url=$2
    if curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null | grep -q "200\|301\|302"; then
        echo -e "  $name: ${GREEN}OK${NC}"
    else
        echo -e "  $name: ${RED}FAIL${NC}"
    fi
}

echo ""
echo "Infrastructure Services:"
check_tcp "FalkorDB" 6379
check_tcp "RedisVL" 6380

echo ""
echo "Application Services:"
check_http "Cognee API" "http://localhost:8000"
check_http "NocoDB" "http://localhost:8080"
check_http "Grist" "http://localhost:8484"
check_http "RedisInsight" "http://localhost:8001"

echo ""
echo "Container Status:"
docker ps --filter "name=sonik-" --format "table {{.Names}}\t{{.Status}}"
