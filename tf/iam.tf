# Service Account (IAM User)
resource "aws_iam_user" "service_account" {
  name = "lti-service-account"
  path = "/system/"

  tags = {
    Name = "LTI Service Account"
    app  = var.app_name
  }
}

# Access key for the service account
resource "aws_iam_access_key" "service_account_key" {
  user = aws_iam_user.service_account.name
}

# Role for the service account
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
      },
    ]
  })

  tags = {
    Name = "LTI App Role"
    app  = var.app_name
  }
}

# Policy to manage EC2 instances
resource "aws_iam_policy" "ec2_management_policy" {
  name        = "EC2ManagementPolicy"
  description = "Policy to create and manage EC2 instances"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:RunInstances",
          "ec2:StartInstances",
          "ec2:StopInstances",
          "ec2:TerminateInstances",
          "ec2:DescribeInstances",
          "ec2:CreateTags",
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Policy to manage security groups
resource "aws_iam_policy" "security_policy" {
  name        = "SecurityGroupPolicy"
  description = "Policy to configure security rules"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:CreateSecurityGroup",
          "ec2:DescribeSecurityGroups",
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Policy to manage S3 buckets
resource "aws_iam_policy" "s3_management_policy" {
  name        = "S3ManagementPolicy"
  description = "Policy to create and manage S3 buckets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:CreateBucket",
          "s3:DeleteBucket",
          "s3:PutBucketPolicy",
          "s3:GetBucketPolicy",
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Policy for app to access S3 buckets with prefix lt
resource "aws_iam_policy" "s3_lti_access_policy" {
  name        = "S3LTIAccessPolicy"
  description = "Policy to access S3 buckets with prefix lt"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
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

# Policy for CloudWatch logs management
resource "aws_iam_policy" "logs_management_policy" {
  name        = "LogsManagementPolicy"
  description = "Policy to manage CloudWatch logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",
          "logs:GetLogEvents",
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Attach policies to service account
resource "aws_iam_user_policy_attachment" "ec2_policy_attachment" {
  user       = aws_iam_user.service_account.name
  policy_arn = aws_iam_policy.ec2_management_policy.arn
}

resource "aws_iam_user_policy_attachment" "security_policy_attachment" {
  user       = aws_iam_user.service_account.name
  policy_arn = aws_iam_policy.security_policy.arn
}

resource "aws_iam_user_policy_attachment" "s3_policy_attachment" {
  user       = aws_iam_user.service_account.name
  policy_arn = aws_iam_policy.s3_management_policy.arn
}

# Attach policies to role
resource "aws_iam_role_policy_attachment" "s3_lti_policy_attachment" {
  role       = aws_iam_role.lti_app_role.name
  policy_arn = aws_iam_policy.s3_lti_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "logs_policy_attachment" {
  role       = aws_iam_role.lti_app_role.name
  policy_arn = aws_iam_policy.logs_management_policy.arn
}

# Instance profile to attach to EC2 instances
resource "aws_iam_instance_profile" "lti_instance_profile" {
  name = "lti-instance-profile"
  role = aws_iam_role.lti_app_role.name
} 