module "appointmentservice-application" {
  source = "./modules/elb-postgres-application"

  application_name = "appointmentservice"
  s3_bucket_id     = var.s3_bucket_id
  environment      = var.environment
  db_instance_type = "db.t2.micro"
  instance_type    = "t2.micro"
  private_subnets  = module.vpc.private_subnets
  vpc_id           = module.vpc.vpc_id
  region           = var.region
  aws_access_key   = var.aws_access_key
  aws_secret_key   = var.aws_secret_key
  security_group   = aws_security_group.elasticbeanstalk_vpc_endpoint.id

  depends_on_endpoints = [
    aws_vpc_endpoint.ec2,
    aws_vpc_endpoint.elasticbeanstalk,
    aws_vpc_endpoint.s3,
    aws_vpc_endpoint.elasticbeanstalk-hc
  ]
}