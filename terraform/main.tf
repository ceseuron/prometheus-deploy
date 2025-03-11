data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

module "vpc" {
  source     = "./vpc"
  aws_region = var.aws_region
  vpc_name   = "prometheus-deploy-vpc"
  vpc_cidr   = "172.32.0.0/16"
}

module "ec2" {
  source                = "./ec2"
  instance_count        = 2
  public_subnets        = module.vpc.public_subnets
  private_subnets       = module.vpc.private_subnets
  aws_vpc_id            = module.vpc.vpc_id
  aws_region            = var.aws_region
  aws_ec2_name          = "prometheus"
  aws_ec2_instance_type = "t2.micro"
  aws_secret_name       = "aws-ec2-ssh-key"
}

