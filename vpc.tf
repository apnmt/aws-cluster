data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.2.0"

  name                 = "aws-cluster"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_security_group" "elasticbeanstalk_vpc_endpoint" {
  name   = "elasticbeanstalk-vpc-endpoint"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc_endpoint" "elasticbeanstalk" {
  vpc_id       = module.vpc.vpc_id
  service_name = "com.amazonaws.${var.region}.elasticbeanstalk"

  subnet_ids = module.vpc.private_subnets

  security_group_ids = [
    aws_security_group.elasticbeanstalk_vpc_endpoint.id,
  ]

  vpc_endpoint_type = "Interface"

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ec2" {
  vpc_id       = module.vpc.vpc_id
  service_name = "com.amazonaws.${var.region}.ec2"

  subnet_ids = module.vpc.private_subnets

  security_group_ids = [
    aws_security_group.elasticbeanstalk_vpc_endpoint.id,
  ]

  vpc_endpoint_type = "Interface"

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = module.vpc.vpc_id
  service_name = "com.amazonaws.${var.region}.s3"

  route_table_ids = [module.vpc.default_route_table_id]
}

resource "aws_vpc_endpoint" "elasticbeanstalk-hc" {
  vpc_id       = module.vpc.vpc_id
  service_name = "com.amazonaws.${var.region}.elasticbeanstalk-health"

  subnet_ids = module.vpc.private_subnets

  security_group_ids = [
    aws_security_group.elasticbeanstalk_vpc_endpoint.id,
  ]

  private_dns_enabled = true

  vpc_endpoint_type = "Interface"
}

resource "aws_vpc_endpoint" "cloudformation" {
  vpc_id       = module.vpc.vpc_id
  service_name = "com.amazonaws.${var.region}.cloudformation"

  subnet_ids = module.vpc.private_subnets

  security_group_ids = [
    aws_security_group.elasticbeanstalk_vpc_endpoint.id,
  ]

  private_dns_enabled = true

  vpc_endpoint_type = "Interface"
}

resource "aws_vpc_endpoint" "sns" {
  vpc_id       = module.vpc.vpc_id
  service_name = "com.amazonaws.${var.region}.sns"

  subnet_ids = module.vpc.private_subnets

  security_group_ids = [
    aws_security_group.elasticbeanstalk_vpc_endpoint.id,
  ]

  private_dns_enabled = true

  vpc_endpoint_type = "Interface"
}

resource "aws_vpc_endpoint" "sqs" {
  vpc_id       = module.vpc.vpc_id
  service_name = "com.amazonaws.${var.region}.sqs"

  subnet_ids = module.vpc.private_subnets

  security_group_ids = [
    aws_security_group.elasticbeanstalk_vpc_endpoint.id,
  ]

  private_dns_enabled = true

  vpc_endpoint_type = "Interface"
}