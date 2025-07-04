variable "vpc_flow_logs_bucket_name" {
  description = "Name of the S3 bucket for data"
  type        = string
}

variable "ec2_data_bucket_name" {
  description = "Name of the S3 bucket for EC2 data"
  type        = string
}

variable "name_flow_log_role" {
  description = "The ARN of the S3 bucket where VPC Flow Logs will be stored"
  type        = string
}