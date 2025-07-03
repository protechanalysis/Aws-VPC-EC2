output "vpc_flow_logs_bucket_name" {
  description = "Name of the VPC Flow Logs S3 bucket"
  value       = aws_s3_bucket.vpc_flow_logs.bucket
}

output "vpc_flow_logs_bucket_arn" {
  description = "ARN of the VPC Flow Logs S3 bucket"
  value       = aws_s3_bucket.vpc_flow_logs.arn
}

output "ec2_data_bucket_name" {
  description = "Name of the EC2 data S3 bucket"
  value       = aws_s3_bucket.ec2_data.bucket
}

output "ec2_data_bucket_arn" {
  description = "ARN of the EC2 data S3 bucket"
  value       = aws_s3_bucket.ec2_data.arn
}

output "ec2_instance_profile_name" {
  description = "Name of the EC2 instance profile for S3 access"
  value       = aws_iam_instance_profile.ec2_profile.name
}

output "vpc_flow_logs_role_arn" {
  description = "Name of the IAM role for VPC Flow Logs"
  value       = aws_iam_role.vpc_flow_logs_role.arn
  
}