# Backend EC2 instance
resource "aws_instance" "lti_backend" {
  ami                    = var.ubuntu_ami
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.lti_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.lti_instance_profile.name

  # User data script to install Docker and other dependencies
  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y docker.io docker-compose
              systemctl enable docker
              systemctl start docker
              EOF

  tags = {
    Name = "LTI Backend Server"
    app  = "${var.app_name}-backend"
  }

  # Root volume configuration
  root_block_device {
    volume_size           = 20
    volume_type           = "gp2"
    delete_on_termination = true
    tags = {
      Name = "LTI Backend Root Volume"
    }
  }
}

# Frontend EC2 instance
resource "aws_instance" "lti_frontend" {
  ami                    = var.ubuntu_ami
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.lti_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.lti_instance_profile.name

  # User data script to install Nginx and other dependencies
  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y nginx
              systemctl enable nginx
              systemctl start nginx
              EOF

  tags = {
    Name = "LTI Frontend Server"
    app  = "${var.app_name}-frontend"
  }

  # Root volume configuration
  root_block_device {
    volume_size           = 20
    volume_type           = "gp2"
    delete_on_termination = true
    tags = {
      Name = "LTI Frontend Root Volume"
    }
  }
} 