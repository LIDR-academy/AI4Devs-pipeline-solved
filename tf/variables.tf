variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-north-1"  # Stockholm region
}

variable "my_ip" {
  description = "Your IP address for SSH access"
  type        = string
  default     = "180.200.1.200"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "lti-recruiting"
} 