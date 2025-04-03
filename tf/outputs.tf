output "service_account_id" {
  description = "ID of the service account"
  value       = aws_iam_user.service_account.id
}

output "service_account_access_key" {
  description = "Access key ID for the service account"
  value       = aws_iam_access_key.service_account_key.id
  sensitive   = false
}

output "service_account_secret_key" {
  description = "Secret access key for the service account"
  value       = aws_iam_access_key.service_account_key.secret
  sensitive   = true
}

output "backend_instance_id" {
  description = "ID of the backend instance"
  value       = aws_instance.backend.id
}

output "backend_public_ip" {
  description = "Public IP of the backend instance"
  value       = aws_instance.backend.public_ip
}

output "frontend_instance_id" {
  description = "ID of the frontend instance"
  value       = aws_instance.frontend.id
}

output "frontend_public_ip" {
  description = "Public IP of the frontend instance"
  value       = aws_instance.frontend.public_ip
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.app_sg.id
} 