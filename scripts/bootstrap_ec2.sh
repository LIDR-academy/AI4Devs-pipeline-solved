#!/usr/bin/env bash
set -euo pipefail

# Bootstrap script for EC2 instance (Amazon Linux 2 or Ubuntu)
# Usage: ssh -i key.pem ec2-user@EC2_IP 'bash -s' < bootstrap_ec2.sh

echo "Starting EC2 bootstrap..."

OS="unknown"
if [ -f /etc/os-release ]; then
  . /etc/os-release
  OS=$ID
fi

echo "Detected OS: $OS"

if command -v yum &> /dev/null; then
  echo "Using yum (likely Amazon Linux)"
  sudo yum update -y
  sudo yum install -y git curl jq
  # Install nginx
  sudo yum install -y nginx
  sudo systemctl enable --now nginx
else
  echo "Assuming apt (Ubuntu/Debian)"
  sudo apt-get update -y
  sudo apt-get install -y git curl jq nginx
  sudo systemctl enable --now nginx
fi

# Install nvm and node LTS
if ! command -v node &> /dev/null; then
  echo "Installing nvm and Node.js LTS"
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  # shellcheck source=/dev/null
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  nvm install --lts
fi

# Install pm2
if ! command -v pm2 &> /dev/null; then
  npm install -g pm2
fi

# Install AWS CLI v2 if not present
if ! command -v aws &> /dev/null; then
  echo "Installing AWS CLI v2"
  TMPDIR=$(mktemp -d)
  cd "$TMPDIR"
  if [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
  else
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
  fi
  cd -
fi

echo "Creating app directory /home/ec2-user/backend"
mkdir -p /home/ec2-user/backend
chown -R ec2-user:ec2-user /home/ec2-user/backend

echo "Bootstrap finished"
