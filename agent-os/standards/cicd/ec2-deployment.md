# EC2 Deployment Strategy

Deploy application code to EC2 instances using AWS S3 as an intermediate artifact repository, PM2 as the process runner, and Nginx as a reverse proxy.

## Guidelines

- **S3 Intermediate Artifact Storage**:
  - Upload build artifacts/code to a secure, centralized AWS S3 bucket during the deployment pipeline.
  - The target EC2 instance must download the artifacts from S3, separating the build environment from the deployment target.
- **Process Management with PM2**:
  - Run the Node.js backend under PM2 to ensure the application automatically restarts on failures or server reboots.
  - Run the application on a dedicated port (default `8080`).
- **Nginx Reverse Proxy**:
  - Configure Nginx on the EC2 instance to listen on port `80`.
  - Route incoming traffic as a reverse proxy from port `80` to the internal PM2 server port `8080`.

### Infrastructure Architecture

```
Internet (Port 80) ➔ Nginx ➔ PM2 (Port 8080)
                      ▲
                      │ (Downloads code)
                  AWS S3 Bucket
                      ▲
                      │ (Uploads code)
               CI/CD Runner
```

### Config Example (Nginx Proxy)

```nginx
server {
    listen 80;
    server_name example.com;
    
    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```
