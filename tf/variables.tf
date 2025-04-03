variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "admin_ip" {
  description = "IP address allowed for SSH access"
  type        = string
  default     = "0.0.0.0/0" # Replace with your actual IP
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.small"
}

variable "app_name" {
  description = "Application name for tagging resources"
  type        = string
  default     = "lti-recruiting"
}

variable "ubuntu_ami" {
  description = "Ubuntu 22.04 AMI ID for the specified region"
  type        = string
  default     = "ami-0e83be366243f524a" # Ubuntu 22.04 LTS AMI ID for us-east-1
} 