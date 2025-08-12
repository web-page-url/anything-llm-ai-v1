# Test Docker Build and Run Script for Aditi Consulting AI
# PowerShell version for Windows

Write-Host "🧪 Testing Docker build for Aditi Consulting AI..." -ForegroundColor Cyan

# Function to print colored output
function Write-Success {
    param($Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Warning {
    param($Message)
    Write-Host "⚠️  $Message" -ForegroundColor Yellow
}

function Write-Error {
    param($Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

# Check if Docker is running
try {
    docker info | Out-Null
    Write-Success "Docker is running"
} catch {
    Write-Error "Docker is not running. Please start Docker and try again."
    exit 1
}

# Build the Docker image
Write-Host "🔨 Building Docker image..." -ForegroundColor Cyan
try {
    docker build -t aditi-consulting-ai:test .
    Write-Success "Docker image built successfully"
} catch {
    Write-Error "Docker build failed"
    exit 1
}

# Test run the container
Write-Host "🚀 Testing container startup..." -ForegroundColor Cyan
try {
    $ContainerId = docker run -d `
        -p 3001:3001 `
        -e NODE_ENV=production `
        -e JWT_SECRET=test-jwt-secret-32-characters-long `
        -e SIG_KEY=test-signature-key-32-characters-long `
        -e SIG_SALT=test-salt-key-32-characters-long-req `
        --name aditi-test `
        aditi-consulting-ai:test
    
    Write-Success "Container started with ID: $ContainerId"
} catch {
    Write-Error "Failed to start container"
    exit 1
}

# Wait for the application to start
Write-Host "⏳ Waiting for application to start (60 seconds)..." -ForegroundColor Cyan
Start-Sleep -Seconds 60

# Test health check
Write-Host "🏥 Testing health check endpoint..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3001/api/ping" -UseBasicParsing -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Success "Health check passed - application is responding"
    } else {
        Write-Warning "Health check returned status code: $($response.StatusCode)"
    }
} catch {
    Write-Warning "Health check failed - checking container logs..."
    docker logs aditi-test --tail 50
}

# Show container status
Write-Host "📊 Container status:" -ForegroundColor Cyan
docker ps --filter name=aditi-test

# Show logs
Write-Host "📝 Recent container logs:" -ForegroundColor Cyan
docker logs aditi-test --tail 20

# Cleanup
Write-Host "🧹 Cleaning up test container..." -ForegroundColor Cyan
docker stop aditi-test | Out-Null
docker rm aditi-test | Out-Null

Write-Success "Test completed! If health check passed, your Docker image is ready for Railway deployment."

Write-Host ""
Write-Host "🚀 To deploy to Railway:" -ForegroundColor Cyan
Write-Host "1. Push your code to GitHub"
Write-Host "2. Connect your GitHub repo to Railway"
Write-Host "3. Railway will automatically build and deploy using the Dockerfile"
Write-Host "4. Set your environment variables in Railway dashboard"
Write-Host ""
Write-Host "📖 See RAILWAY_DEPLOYMENT.md for detailed instructions" -ForegroundColor Yellow