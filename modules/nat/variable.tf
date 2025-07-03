variable "name" {
  description = "Name tag for NAT Gateway and EIP"
  type        = string
}

variable "public_subnet_id" {
  description = "Subnet ID where the NAT Gateway will be created"
  type        = string
  
}