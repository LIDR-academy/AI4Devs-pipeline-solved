terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "eu-west-1"
}

# IAM Service Account
resource "aws_iam_user" "lti_service_account" {
  name = "lti-service-account"
  tags = {
    Description = "Cuenta de servicio para la aplicación LTI"
  }
}

# Policy para gestión de instancias EC2
resource "aws_iam_policy" "ec2_management" {
  name        = "lti-ec2-management"
  description = "Permite gestionar instancias EC2"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:RunInstances",
          "ec2:TerminateInstances",
          "ec2:StartInstances",
          "ec2:StopInstances",
          "ec2:DescribeInstances",
          "ec2:CreateTags",
          "ec2:DescribeTags"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Policy para gestión de reglas de seguridad
resource "aws_iam_policy" "security_management" {
  name        = "lti-security-management"
  description = "Permite configurar reglas de seguridad"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:CreateSecurityGroup",
          "ec2:DescribeSecurityGroups",
          "ec2:DeleteSecurityGroup"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Policy para gestión de buckets S3
resource "aws_iam_policy" "s3_management" {
  name        = "lti-s3-management"
  description = "Permite gestionar buckets S3"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:CreateBucket",
          "s3:ListBucket",
          "s3:DeleteBucket",
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Adjuntar políticas a la cuenta de servicio
resource "aws_iam_user_policy_attachment" "attach_ec2" {
  user       = aws_iam_user.lti_service_account.name
  policy_arn = aws_iam_policy.ec2_management.arn
}

resource "aws_iam_user_policy_attachment" "attach_security" {
  user       = aws_iam_user.lti_service_account.name
  policy_arn = aws_iam_policy.security_management.arn
}

resource "aws_iam_user_policy_attachment" "attach_s3" {
  user       = aws_iam_user.lti_service_account.name
  policy_arn = aws_iam_policy.s3_management.arn
}

# Rol IAM
resource "aws_iam_role" "lti_app_role" {
  name = "lti-app-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
  
  tags = {
    Description = "Rol para la aplicación LTI"
  }
}

# Policy para acceder a buckets S3 que empiecen por "lt"
resource "aws_iam_policy" "s3_lt_access" {
  name        = "s3-lt-access"
  description = "Permite acceder a buckets S3 que empiecen por lt"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Effect   = "Allow"
        Resource = [
          "arn:aws:s3:::lt*",
          "arn:aws:s3:::lt*/*"
        ]
      }
    ]
  })
}

# Policy para gestionar logs
resource "aws_iam_policy" "logs_management" {
  name        = "logs-management"
  description = "Permite gestionar logs de actividad"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",
          "logs:DescribeLogGroups"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Adjuntar políticas al rol
resource "aws_iam_role_policy_attachment" "attach_s3_lt" {
  role       = aws_iam_role.lti_app_role.name
  policy_arn = aws_iam_policy.s3_lt_access.arn
}

resource "aws_iam_role_policy_attachment" "attach_logs" {
  role       = aws_iam_role.lti_app_role.name
  policy_arn = aws_iam_policy.logs_management.arn
}

# Grupo de Seguridad
resource "aws_security_group" "lti_sg" {
  name        = "lti-security-group"
  description = "Grupo de seguridad para instancias LTI"
  
  # Regla para acceso SSH desde IP específica
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
    description = "Acceso SSH desde IP específica"
  }
  
  # Regla para acceso HTTP desde cualquier lugar
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Acceso HTTP desde cualquier lugar"
  }
  
  # Regla para permitir todo el tráfico saliente
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Permite todo el tráfico saliente"
  }
  
  tags = {
    Name = "lti-security-group"
  }
}

# Perfil de instancia para EC2
resource "aws_iam_instance_profile" "lti_instance_profile" {
  name = "lti-instance-profile"
  role = aws_iam_role.lti_app_role.name
}

# Datos de AMI para Ubuntu 22.04
data "aws_ami" "ubuntu_22_04" {
  most_recent = true
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  
  owners = ["099720109477"] # Canonical
}

# Instancia EC2 para Backend
resource "aws_instance" "lti_backend" {
  ami                    = data.aws_ami.ubuntu_22_04.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.lti_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.lti_instance_profile.name
  
  tags = {
    Name = "lti-backend"
    app  = "lti-recruiting-backend"
  }
  
  root_block_device {
    volume_size = 8
    volume_type = "gp2"
  }
}

# Instancia EC2 para Frontend
resource "aws_instance" "lti_frontend" {
  ami                    = data.aws_ami.ubuntu_22_04.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.lti_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.lti_instance_profile.name
  
  tags = {
    Name = "lti-frontend"
    app  = "lti-recruiting-frontend"
  }
  
  root_block_device {
    volume_size = 8
    volume_type = "gp2"
  }
}

# Bucket S3 para la aplicación
resource "aws_s3_bucket" "lt_data_bucket" {
  bucket = "lt-recruiting-data"
  
  tags = {
    Name        = "LTI Recruiting Data"
    Environment = "Dev"
  }
}

# Variables
variable "my_ip" {
  description = "Mi dirección IP para acceso SSH"
  type        = string
  default     = "0.0.0.0/0"  # Reemplazar con tu IP real
}

variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
  default     = "t2.micro"  # Tamaño pequeño
}

# Outputs
output "backend_public_ip" {
  value       = aws_instance.lti_backend.public_ip
  description = "IP pública de la instancia backend"
}

output "frontend_public_ip" {
  value       = aws_instance.lti_frontend.public_ip
  description = "IP pública de la instancia frontend"
}

output "s3_bucket_name" {
  value       = aws_s3_bucket.lt_data_bucket.bucket
  description = "Nombre del bucket S3"
}
