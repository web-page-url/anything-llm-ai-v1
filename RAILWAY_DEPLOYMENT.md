# Railway Deployment Guide for Aditi Consulting AI

This guide will help you deploy Aditi Consulting AI to Railway using Docker.

## Prerequisites

1. Railway account (sign up at [railway.app](https://railway.app))
2. Railway CLI installed (optional but recommended)
3. Git repository with your code

## Quick Deploy (Recommended)

### Option 1: Deploy from GitHub

1. **Connect Repository**
   - Go to [railway.app](https://railway.app)
   - Click "New Project"
   - Select "Deploy from GitHub repo"
   - Choose your repository

2. **Railway will automatically:**
   - Detect the Dockerfile
   - Build the Docker image
   - Deploy the application
   - Assign a public URL

### Option 2: Deploy with Railway CLI

```bash
# Install Railway CLI
npm install -g @railway/cli

# Login to Railway
railway login

# Initialize project
railway init

# Deploy
railway up
```

## Environment Variables

Set these environment variables in Railway dashboard:

### Required Variables
```
NODE_ENV=production
```

### Optional Variables (with defaults)
```
JWT_SECRET=your-jwt-secret-32-characters-minimum
SIG_KEY=your-signature-key-32-characters-minimum
SIG_SALT=your-salt-key-32-characters-minimum
VECTOR_DB=lancedb
LLM_PROVIDER=openai
EMBEDDING_ENGINE=native
TTS_PROVIDER=native
WHISPER_PROVIDER=local
```

### AI Provider Variables (if using external services)
```
# OpenAI
OPENAI_API_KEY=your-openai-api-key

# Anthropic
ANTHROPIC_API_KEY=your-anthropic-api-key

# Other providers as needed
```

## Setting Environment Variables

### Via Railway Dashboard
1. Go to your project dashboard
2. Click on "Variables" tab
3. Add each variable with its value
4. Click "Deploy" to apply changes

### Via Railway CLI
```bash
# Set individual variables
railway variables set NODE_ENV=production
railway variables set JWT_SECRET=your-secret-key

# Set multiple variables from file
railway variables set --file .env.railway
```

## Database Configuration

The application uses SQLite by default, which works perfectly on Railway:
- Database file: `/app/server/storage/anythingllm.db`
- Automatic migrations on startup
- Persistent storage via Railway volumes

## Health Checks

Railway will automatically monitor your application:
- Health check endpoint: `/api/ping`
- Timeout: 300 seconds
- Restart policy: On failure (max 3 retries)

## Troubleshooting

### Build Issues
1. **Check build logs** in Railway dashboard
2. **Common fixes:**
   ```bash
   # Clear Railway cache
   railway run --detach=false bash -c "rm -rf node_modules && yarn install"
   ```

### Runtime Issues
1. **Check application logs** in Railway dashboard
2. **Common issues:**
   - Missing environment variables
   - Database connection issues
   - Port binding problems

### Memory Issues
- Railway provides 512MB RAM by default
- Upgrade to higher plan if needed
- Monitor memory usage in dashboard

## Custom Domain (Optional)

1. Go to project settings
2. Click "Domains"
3. Add your custom domain
4. Update DNS records as instructed

## Scaling

Railway automatically handles:
- Load balancing
- Auto-scaling based on traffic
- Zero-downtime deployments

## Security Best Practices

1. **Set strong secrets:**
   ```bash
   # Generate secure keys
   openssl rand -hex 32  # For JWT_SECRET
   openssl rand -hex 32  # For SIG_KEY
   openssl rand -hex 32  # For SIG_SALT
   ```

2. **Use environment variables** for all sensitive data
3. **Enable HTTPS** (automatic with Railway)
4. **Regular updates** via git push

## Monitoring

Railway provides built-in monitoring:
- CPU and memory usage
- Request metrics
- Error tracking
- Real-time logs

## Backup Strategy

1. **Database backups:**
   - SQLite file is in persistent storage
   - Download via Railway CLI: `railway run cat /app/server/storage/anythingllm.db > backup.db`

2. **Document storage:**
   - Files stored in `/app/server/storage/documents`
   - Consider external storage for large deployments

## Cost Optimization

1. **Starter Plan:** $5/month - Perfect for small teams
2. **Pro Plan:** $20/month - For production use
3. **Monitor usage** in Railway dashboard

## Support

- Railway Documentation: [docs.railway.app](https://docs.railway.app)
- Railway Discord: [discord.gg/railway](https://discord.gg/railway)
- Application Issues: Check logs in Railway dashboard

## Deployment Checklist

- [ ] Repository connected to Railway
- [ ] Environment variables configured
- [ ] Build completed successfully
- [ ] Application accessible via Railway URL
- [ ] Health check passing
- [ ] Database migrations completed
- [ ] Document upload/processing working
- [ ] AI chat functionality working
- [ ] Custom domain configured (if needed)

## Next Steps

After successful deployment:
1. Test all functionality
2. Set up monitoring alerts
3. Configure backups
4. Add team members
5. Set up CI/CD pipeline (optional)

Your Aditi Consulting AI is now running on Railway! 🚀