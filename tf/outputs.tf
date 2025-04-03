output "backend_public_ip" {
  description = "Public IP address of the LTI backend instance"
  value       = aws_instance.lti_backend.public_ip
}

output "frontend_public_ip" {
  description = "Public IP address of the LTI frontend instance"
  value       = aws_instance.lti_frontend.public_ip
}

output "security_group_id" {
  description = "ID of the security group created"
  value       = aws_security_group.lti_sg.id
}

output "service_account_name" {
  description = "Name of the service account created"
  value       = aws_iam_user.service_account.name
}

output "service_account_access_key" {
  description = "Access key ID for the service account"
  value       = aws_iam_access_key.service_account_key.id
  sensitive   = true
}

output "service_account_secret_key" {
  description = "Secret access key for the service account"
  value       = aws_iam_access_key.service_account_key.secret
  sensitive   = true
}

output "resumes_bucket_name" {
  description = "Name of the S3 bucket for storing resumes"
  value       = aws_s3_bucket.lt_resumes_bucket.bucket
}

output "resumes_bucket_arn" {
  description = "ARN of the S3 bucket for storing resumes"
  value       = aws_s3_bucket.lt_resumes_bucket.arn
} 