#!/bin/bash

# ==========================================
# WURM-KI LOCAL DEPLOYMENT SCRIPT
# ==========================================

set -e  # Exit on error

echo "🚀 Starting Wurm-Ki Local Deployment..."
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if .env exists
if [ ! -f .env ]; then
    echo -e "${YELLOW}⚠️  .env file not found. Creating from .env.production...${NC}"
    cp .env.production .env
    echo -e "${GREEN}✅ Created .env file${NC}"
    echo -e "${YELLOW}⚠️  Please edit .env and set your configuration!${NC}"
    echo ""
    read -p "Press enter to continue or Ctrl+C to abort..."
fi

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not running. Please start Docker first.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Docker is running${NC}"
echo ""

# Check if Ollama is accessible
OLLAMA_URL=$(grep OLLAMA_BASE_URL .env | cut -d '=' -f2 | tr -d '"' | tr -d "'")
if [ -z "$OLLAMA_URL" ]; then
    OLLAMA_URL="http://localhost:11434"
fi

echo "🔍 Checking Ollama connection at $OLLAMA_URL..."
if curl -s "$OLLAMA_URL/api/version" > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Ollama is accessible${NC}"
else
    echo -e "${YELLOW}⚠️  Warning: Cannot connect to Ollama at $OLLAMA_URL${NC}"
    echo -e "${YELLOW}   Make sure Ollama is running or update OLLAMA_BASE_URL in .env${NC}"
    echo ""
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi
echo ""

# Stop existing containers
echo "🛑 Stopping existing containers..."
docker-compose down
echo -e "${GREEN}✅ Stopped${NC}"
echo ""

# Build new image
echo "🔨 Building Docker image (this may take a few minutes)..."
docker-compose build --no-cache
echo -e "${GREEN}✅ Build complete${NC}"
echo ""

# Start containers
echo "🚀 Starting Wurm-Ki..."
docker-compose up -d
echo -e "${GREEN}✅ Wurm-Ki is starting${NC}"
echo ""

# Wait for container to be healthy
echo "⏳ Waiting for Wurm-Ki to be ready..."
sleep 5

# Check if container is running
if docker-compose ps | grep -q "wurm-ki.*Up"; then
    echo -e "${GREEN}✅ Wurm-Ki is running!${NC}"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${GREEN}🎉 Deployment successful!${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "📍 Access Wurm-Ki at: http://localhost:3000"
    echo ""
    echo "📊 View logs:"
    echo "   docker-compose logs -f"
    echo ""
    echo "🛑 Stop Wurm-Ki:"
    echo "   docker-compose down"
    echo ""
else
    echo -e "${RED}❌ Container failed to start. Checking logs...${NC}"
    docker-compose logs
    exit 1
fi
