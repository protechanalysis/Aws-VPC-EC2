resource "aws_flow_log" "vpc_flow_logs" {
  log_destination      = var.log_destination
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = var.vpc_id
  # iam_role_arn         = var.iam_role_arn
  
  log_format = "$${version} $${account-id} $${interface-id} $${srcaddr} $${dstaddr} $${srcport} $${dstport} $${protocol} $${packets} $${bytes} $${start} $${end} $${action} $${log-status}"

  tags = {
    Environment = "practise"
  }
}