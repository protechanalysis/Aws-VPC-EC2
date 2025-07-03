resource "aws_s3_bucket" "vpc_flow_logs" {
  bucket = var.vpc_flow_logs_bucket_name

  tags = {
    Environment = "practise"
  }
}

resource "aws_s3_bucket" "ec2_data" {
  bucket = var.ec2_data_bucket_name

  tags = {
    Environment = "practise"
  }
}

resource "aws_s3_bucket_versioning" "vpc_flow_logs" {
  bucket = aws_s3_bucket.vpc_flow_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 bucket versioning for EC2 data
resource "aws_s3_bucket_versioning" "ec2_data" {
  bucket = aws_s3_bucket.ec2_data.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 bucket encryption for VPC Flow Logs
resource "aws_s3_bucket_server_side_encryption_configuration" "vpc_flow_logs" {
  bucket = aws_s3_bucket.vpc_flow_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# S3 bucket encryption for EC2 data
resource "aws_s3_bucket_server_side_encryption_configuration" "ec2_data" {
  bucket = aws_s3_bucket.ec2_data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# Block public access for VPC Flow Logs bucket
resource "aws_s3_bucket_public_access_block" "vpc_flow_logs" {
  bucket = aws_s3_bucket.vpc_flow_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Block public access for EC2 data bucket
resource "aws_s3_bucket_public_access_block" "ec2_data" {
  bucket = aws_s3_bucket.ec2_data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


# Lifecycle policy for VPC Flow Logs (cost optimization)
resource "aws_s3_bucket_lifecycle_configuration" "vpc_flow_logs_cycle" {
  bucket = aws_s3_bucket.vpc_flow_logs.id

  rule {
    id     = "flow_logs_lifecycle"
    status = "Enabled"

    filter {
    prefix = ""
    }

    # Move to IA after 30 days
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    # Move to Glacier after 90 days
    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    # Delete after 365 days
    expiration {
      days = 365
    }

    # Clean up incomplete multipart uploads
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# IAM role for VPC Flow Logs
resource "aws_iam_role" "vpc_flow_logs_role" {
  name = var.name_flow_log_role

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Environment = "practise"
  }
}

# IAM policy for VPC Flow Logs to write to S3
resource "aws_iam_role_policy" "vpc_flow_logs_s3" {
  name = "vpc-flow-logs-s3-policy"
  role = aws_iam_role.vpc_flow_logs_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetBucketAcl",
          "s3:ListBucket"
        ]
        Resource = [
          "${aws_s3_bucket.vpc_flow_logs.arn}",
          "${aws_s3_bucket.vpc_flow_logs.arn}/*"
        ]
      }
    ]
  })
}

# IAM role for EC2 instances to access S3
resource "aws_iam_role" "ec2_s3_role" {
  name = "ec2-s3-access-role"

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
    Environment = "practise"
  }
}

# IAM policy for EC2 to access S3 bucket
resource "aws_iam_role_policy" "ec2_s3_policy" {
  name = "ec2-s3-access-policy"
  role = aws_iam_role.ec2_s3_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "${aws_s3_bucket.ec2_data.arn}",
          "${aws_s3_bucket.ec2_data.arn}/*"
        ]
      }
    ]
  })
}

# IAM instance profile for EC2
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-s3-profile"
  role = aws_iam_role.ec2_s3_role.name
}
