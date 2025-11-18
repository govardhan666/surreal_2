# Deployment Guide

This guide walks you through deploying IPulse Studio to production.

## Prerequisites

- Node.js 18+
- PostgreSQL database
- Redis server
- Story Protocol testnet/mainnet access
- API keys for AI services
- IPFS node or Pinata account

## Step 1: Environment Setup

### 1.1 Clone the Repository

```bash
git clone https://github.com/govardhan666/surreal_2.git
cd surreal_2
```

### 1.2 Install Dependencies

```bash
npm install
```

### 1.3 Configure Environment Variables

```bash
cp .env.example .env
```

Edit `.env` with your configuration:

```env
# Story Protocol
STORY_RPC_URL=https://rpc.odyssey.storyrpc.io
STORY_API_KEY=your_api_key

# Database
DATABASE_URL=postgresql://user:password@localhost:5432/ipulse

# AI Services
OPENAI_API_KEY=your_openai_key
STABILITY_API_KEY=your_stability_key

# IPFS
IPFS_API_URL=https://api.pinata.cloud
IPFS_API_KEY=your_pinata_key
```

## Step 2: Database Setup

### 2.1 Create Database

```bash
createdb ipulse_studio
```

### 2.2 Run Migrations

```bash
npm run db:migrate
```

## Step 3: Smart Contract Deployment

### 3.1 Compile Contracts

```bash
npm run contracts:compile
```

### 3.2 Deploy to Story Testnet

```bash
npm run contracts:deploy
```

Save the deployed contract addresses and update `.env`:

```env
NEXT_PUBLIC_MARKETPLACE_ADDRESS=0x...
NEXT_PUBLIC_ROYALTY_DISTRIBUTOR_ADDRESS=0x...
NEXT_PUBLIC_DERIVATIVE_TRACKER_ADDRESS=0x...
```

### 3.3 Verify Contracts

```bash
cd contracts
npx hardhat verify --network story-testnet DEPLOYED_ADDRESS
```

## Step 4: Build SDK

```bash
npm run sdk:build
```

## Step 5: Deploy Frontend

### 5.1 Build Frontend

```bash
cd frontend
npm run build
```

### 5.2 Deploy to Vercel

```bash
npm install -g vercel
vercel --prod
```

Or deploy to your own server:

```bash
npm run start
```

### 5.3 Configure Domain

Update your domain DNS to point to the deployment.

## Step 6: Deploy Backend Services

### 6.1 Backend API

```bash
cd backend
npm run build
npm run start
```

### 6.2 AI Engine

```bash
cd ai-engine
npm run build
npm run start
```

### 6.3 Configure Reverse Proxy (Nginx)

```nginx
server {
    listen 80;
    server_name api.ipulse.studio;

    location / {
        proxy_pass http://localhost:4000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

## Step 7: Monitoring & Logging

### 7.1 Set up PM2

```bash
npm install -g pm2

# Start services
pm2 start npm --name "ipulse-backend" -- run start
pm2 start npm --name "ipulse-ai" -- run start

# Save configuration
pm2 save

# Setup startup script
pm2 startup
```

### 7.2 Configure Logging

```bash
pm2 install pm2-logrotate
pm2 set pm2-logrotate:max_size 10M
pm2 set pm2-logrotate:retain 7
```

## Step 8: Security Checklist

- [ ] Enable HTTPS (Let's Encrypt)
- [ ] Set up firewall rules
- [ ] Configure rate limiting
- [ ] Enable CORS properly
- [ ] Secure API keys in environment
- [ ] Set up database backups
- [ ] Enable monitoring alerts
- [ ] Review smart contract audits

## Step 9: Post-Deployment

### 9.1 Verify Deployment

```bash
# Check frontend
curl https://ipulse.studio

# Check API
curl https://api.ipulse.studio/health

# Check contracts
npm run contracts:test
```

### 9.2 Initialize Platform

```bash
# Configure marketplace fees
# Set up initial licensing templates
# Create test IP assets
```

## Production Checklist

- [ ] All services running
- [ ] Contracts deployed and verified
- [ ] Frontend accessible
- [ ] API endpoints working
- [ ] Database connected
- [ ] IPFS integration working
- [ ] AI services configured
- [ ] Monitoring enabled
- [ ] Backups configured
- [ ] SSL certificates installed
- [ ] DNS configured
- [ ] Documentation updated

## Maintenance

### Daily
- Monitor service health
- Check error logs
- Review API metrics

### Weekly
- Database backups
- Security updates
- Performance review

### Monthly
- Dependency updates
- Security audit
- Cost optimization

## Troubleshooting

### Frontend not loading
```bash
# Check build
cd frontend && npm run build

# Check logs
pm2 logs ipulse-frontend
```

### Contract interaction failing
```bash
# Verify network
npm run contracts:test

# Check balances
# Verify contract addresses
```

### Database connection issues
```bash
# Test connection
psql $DATABASE_URL

# Check migrations
npm run db:migrate
```

## Support

For deployment issues:
- Check GitHub Issues
- Join Discord community
- Contact team@ipulse.studio

---

**Deployment successful!** 🚀
