variable "log_destination" {
  description = "The ARN of the S3 bucket where VPC flow logs will be stored"
  type        = string
  
}

variable "vpc_id" {
  description = "The ID of the VPC for which flow logs will be created"
  type        = string
  
}

# variable "iam_role_arn" {
#   description = "The ID of the VPC for which flow logs will be created"
#   type        = string
  
# }