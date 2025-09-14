# EC2 setup for backend deployment

This document describes how to prepare an EC2 instance to receive the backend deployment from the GitHub Actions workflow.

Supported OS: Amazon Linux 2 (ec2-user) and Ubuntu (ubuntu)

1) Security Group
- Open inbound rules for:
  - SSH (22) - restrict to your IP for security
  - HTTP (80) - `0.0.0.0/0`
  - (Optional) 8080 if you want direct access

2) Copy SSH public key

On your local machine:

```bash
ssh-keygen -f deploy_key -N ""    # if you need a new key
ssh-copy-id -i deploy_key.pub ec2-user@EC2_PUBLIC_IP
```

Or manually add the public key to `/home/ec2-user/.ssh/authorized_keys`.

3) Run bootstrap script (recommended)

From your local machine (replace key and IP):

```bash
cat scripts/bootstrap_ec2.sh | ssh -i path/to/deploy_key ec2-user@EC2_PUBLIC_IP 'bash -s'
```

This script installs nginx, Node (via nvm), pm2 and AWS CLI.

4) Verify nginx and node

```bash
ssh -i path/to/deploy_key ec2-user@EC2_PUBLIC_IP
sudo systemctl status nginx
node -v
pm2 -v
```

5) Ensure AWS CLI can be used by the deploy script

The GitHub Actions workflow uploads the code to S3; the EC2 will download using the AWS CLI installed on the instance. The workflow will pass AWS credentials as environment variables inside the SSH session, so you don't need to configure `~/.aws/credentials` on the EC2.

6) User note

- The workflow assumes the remote user is `ec2-user`. If your AMI uses `ubuntu` change the user in the workflow and docs.
