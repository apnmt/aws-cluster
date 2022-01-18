module "appointmentservice-application" {
  source = "./modules/elb-postgres-application"

  application_name = "appointmentservice"
  environment      = var.environment
  db_instance_type = "db.t2.micro"
  instance_type    = "t2.micro"
  public_subnets   = module.vpc.public_subnets
  private_subnets  = module.vpc.private_subnets
  vpc_id           = module.vpc.vpc_id
  region           = var.region
  aws_access_key   = var.aws_access_key
  aws_secret_key   = var.aws_secret_key
}