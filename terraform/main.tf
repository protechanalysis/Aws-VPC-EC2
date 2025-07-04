module "vpc" {
  source               = "./modules/vpc"
  name                 = "custom-vpc"
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

module "public_subnet" {
  source = "./modules/subnets"

  vpc_id                  = module.vpc.vpc_id
  map_public_ip_on_launch = true

  subnets = [
    {
      name = "public-1"
      cidr = "10.0.1.0/24"
      az   = "us-east-1a"
    },
    {
      name = "public-2"
      cidr = "10.0.2.0/24"
      az   = "us-east-1b"
    }
  ]
}

module "private_subnet" {
  source = "./modules/subnets"

  vpc_id                  = module.vpc.vpc_id
  map_public_ip_on_launch = false

  subnets = [
    {
      name = "private-1"
      cidr = "10.0.3.0/24"
      az   = "us-east-1a"
    },

    {
      name = "private-2"
      cidr = "10.0.4.0/24"
      az   = "us-east-1b"

    }
  ]
}

module "igw" {
  source = "./modules/internet_gateway"

  vpc_id = module.vpc.vpc_id
  name   = "vpc-igw"
}

module "public_route_table" {
  source = "./modules/routes_tables"

  vpc_id     = module.vpc.vpc_id
  name       = "public-rt"
  type       = "public"
  route_cidr = "0.0.0.0/0"
  gateway_id = module.igw.igw_id
  subnet_ids = module.public_subnet.subnet_ids

}

module "private_route_table" {
  source         = "./modules/routes_tables"
  vpc_id         = module.vpc.vpc_id
  name           = "private-rt"
  type           = "private"
  route_cidr     = "0.0.0.0/0"
  nat_gateway_id = module.nat_gateway.nat_gateway_id
  subnet_ids     = module.private_subnet.subnet_ids
}

module "nat_gateway" {
  source           = "./modules/nat"
  public_subnet_id = module.public_subnet.subnet_ids["public-1"]
  name             = "nat-gateway"
  depends_on = [
    module.public_subnet,
    module.igw,
    module.public_route_table
  ]
}

module "ec2_instance" {
  source            = "./modules/bastion"
  name              = "bastion"
  instance_type     = "t3.micro"
  vpc_id            = module.vpc.vpc_id
  public_subnet_id  = module.public_subnet.subnet_ids["public-1"]
  security_group_id = [module.group_security.id]
  # key_name          = data.aws_key_pair.manual_key_pair.key_name

  ssh_allowed_cidr_blocks = ["0.0.0.0/0"]


  tags = {
    Environment = "dev"
    Project     = "demo"
  }
}

module "private_ec2_instance" {
  source            = "./modules/private_ec2"
  name              = "web-server-test"
  instance_type     = "t3.micro"
  vpc_id            = module.vpc.vpc_id
  private_subnet_id  = module.private_subnet.subnet_ids["private-1"]
  security_group_id = [module.group_security.id]
  # key_name          = data.aws_key_pair.manual_key_pair.key_name

  ssh_allowed_cidr_blocks = ["0.0.0.0/0"]


  tags = {
    Environment = "dev"
    Project     = "demo"
  }
}

module "group_security" {
  source      = "./modules/public_security_group"
  name        = "bastion-sg"
  description = "Security group for bastion host"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow HTTP traffic"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow HTTPS traffic"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"] 
      description = "Allow SSH access"
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound traffic"
    }
  ]

  tags = {
    Environment = "dev"
    Project     = "demo"
  }
}

module "private_security_group" {
  source      = "./modules/private_security_group"
  name        = "private-ec2-sg"
  description = "Security group for private EC2 instances"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"] 
      description = "Allow SSH access"
    }
  ]
  
  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound traffic"
    }
  ]

  tags = {
    Environment = "dev"
    Project     = "demo"
  }
}

module "s3" {
  source                    = "./modules/s3"
  vpc_flow_logs_bucket_name = "vpc-flow-logs-test-practise"
  ec2_data_bucket_name      = "ec2-data-test-practise"
  name_flow_log_role        = "vpc-flow-logs-role"
}

module "vpc_flow" {
  source          = "./modules/vpc_flow"
  vpc_id          = module.vpc.vpc_id
  log_destination = module.s3.vpc_flow_logs_bucket_arn
}
