# Service Account (IAM User)
resource "aws_iam_user" "service_account" {
  name = "${var.app_name}-service-account"
}

resource "aws_iam_access_key" "service_account_key" {
  user = aws_iam_user.service_account.name
}

# Service Account Role
resource "aws_iam_role" "service_role" {
  name = "${var.app_name}-service-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

# Policy for EC2 and Security Group management
resource "aws_iam_policy" "instance_management" {
  name        = "${var.app_name}-instance-management"
  description = "Policy for creating and managing EC2 instances and security groups"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:RunInstances",
          "ec2:TerminateInstances",
          "ec2:StartInstances",
          "ec2:StopInstances",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:CreateSecurityGroup",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeInstances"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Policy for S3 management
resource "aws_iam_policy" "s3_management" {
  name        = "${var.app_name}-s3-management"
  description = "Policy for creating and managing S3 buckets"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:CreateBucket",
          "s3:DeleteBucket",
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Policy for specific S3 buckets starting with lt
resource "aws_iam_policy" "lt_buckets" {
  name        = "${var.app_name}-lt-buckets"
  description = "Policy for accessing S3 buckets starting with lt"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
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

# Policy for CloudWatch Logs
resource "aws_iam_policy" "logs_management" {
  name        = "${var.app_name}-logs-management"
  description = "Policy for managing CloudWatch logs"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Attach policies to role
resource "aws_iam_role_policy_attachment" "instance_management_attachment" {
  role       = aws_iam_role.service_role.name
  policy_arn = aws_iam_policy.instance_management.arn
}

resource "aws_iam_role_policy_attachment" "s3_management_attachment" {
  role       = aws_iam_role.service_role.name
  policy_arn = aws_iam_policy.s3_management.arn
}

resource "aws_iam_role_policy_attachment" "lt_buckets_attachment" {
  role       = aws_iam_role.service_role.name
  policy_arn = aws_iam_policy.lt_buckets.arn
}

resource "aws_iam_role_policy_attachment" "logs_management_attachment" {
  role       = aws_iam_role.service_role.name
  policy_arn = aws_iam_policy.logs_management.arn
}

# Attach policies to user
resource "aws_iam_user_policy_attachment" "instance_management_user" {
  user       = aws_iam_user.service_account.name
  policy_arn = aws_iam_policy.instance_management.arn
}

resource "aws_iam_user_policy_attachment" "s3_management_user" {
  user       = aws_iam_user.service_account.name
  policy_arn = aws_iam_policy.s3_management.arn
} 