# AWS EC2 Deployment Skill

## Description
Manages deployment configurations for AWS EC2 instances including SSH, S3 artifact storage, and server provisioning.

## When to Use
- User asks about deploying to EC2
- User asks about AWS configuration
- User mentions SSH deployment, S3 uploads, or EC2 provisioning
- User wants to configure infrastructure for deployment

## Instructions

### Context Gathering
1. Read `.github/workflows/pipeline.yml` for current deploy steps
2. Read `tf/main.tf` for Terraform infrastructure definitions
3. Check for any deployment scripts in the repository

### EC2 Deployment Best Practices
- Use IAM roles over access keys when possible
- SSH key rotation and proper permissions (chmod 600)
- Health checks after deployment
- Graceful shutdown of old processes before deploy
- Use systemd services for process management
- Configure security groups with least privilege
- Enable CloudWatch logging

### Deployment Flow
```
1. Build artifacts → 2. Upload to S3 → 3. SSH into EC2 → 4. Pull from S3 → 5. Install deps → 6. Restart service → 7. Health check
```

### Required Secrets (GitHub)
- `AWS_ACCESS_ID` — AWS access key ID
- `AWS_ACCESS_KEY` — AWS secret access key
- `EC2_INSTANCE` — EC2 public IP or hostname
- `EC2_SSH_PRIVATE_KEY` — SSH private key for EC2 access

### EC2 Deployment Script Template
```bash
#!/bin/bash
set -e

# Pull latest code from S3
aws s3 sync s3://bucket/backend/ /app/backend/

# Install dependencies
cd /app/backend
npm ci --production

# Restart application
sudo systemctl restart app

# Health check
sleep 5
curl -f http://localhost:3010/health || exit 1
echo "Deployment successful"
```

### Security Checklist
- [ ] No secrets printed in logs
- [ ] SSH keys removed after use in CI
- [ ] Security groups restrict access to necessary ports only
- [ ] HTTPS enabled for production traffic
- [ ] Environment variables for sensitive config
