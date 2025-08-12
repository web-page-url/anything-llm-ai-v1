#!/bin/bash

# Test Docker Build and Run Script for Aditi Consulting AI
set -e

echo "🧪 Testing Docker build for Aditi Consulting AI..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker and try again."
    exit 1
fi

print_status "Docker is running"

# Build the Docker image
echo "🔨 Building Docker image..."
if docker build -t aditi-consulting-ai:test .; then
    print_status "Docker image built successfully"
else
    print_error "Docker build failed"
    exit 1
fi

# Test run the container
echo "🚀 Testing container startup..."
CONTAINER_ID=$(docker run -d \
    -p 3001:3001 \
    -e NODE_ENV=production \
    -e JWT_SECRET=test-jwt-secret-32-characters-long \
    -e SIG_KEY=test-signature-key-32-characters-long \
    -e SIG_SALT=test-salt-key-32-characters-long-req \
    --name aditi-test \
    aditi-consulting-ai:test)

if [ $? -eq 0 ]; then
    print_status "Container started with ID: $CONTAINER_ID"
else
    print_error "Failed to start container"
    exit 1
fi

# Wait for the application to start
echo "⏳ Waiting for application to start (60 seconds)..."
sleep 60

# Test health check
echo "🏥 Testing health check endpoint..."
if curl -f http://localhost:3001/api/ping > /dev/null 2>&1; then
    print_status "Health check passed - application is responding"
else
    print_warning "Health check failed - checking container logs..."
    docker logs aditi-test --tail 50
fi

# Show container status
echo "📊 Container status:"
docker ps --filter name=aditi-test

# Show logs
echo "📝 Recent container logs:"
docker logs aditi-test --tail 20

# Cleanup
echo "🧹 Cleaning up test container..."
docker stop aditi-test > /dev/null 2>&1 || true
docker rm aditi-test > /dev/null 2>&1 || true

print_status "Test completed! If health check passed, your Docker image is ready for Railway deployment."

echo ""
echo "🚀 To deploy to Railway:"
echo "1. Push your code to GitHub"
echo "2. Connect your GitHub repo to Railway"
echo "3. Railway will automatically build and deploy using the Dockerfile"
echo "4. Set your environment variables in Railway dashboard"
echo ""
echo "📖 See RAILWAY_DEPLOYMENT.md for detailed instructions"