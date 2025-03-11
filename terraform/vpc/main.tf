# Get availability zones for the currently defined region.
data "aws_availability_zones" "available" {
  state = "available"

  filter {
    name   = "region-name"
    values = [var.aws_region]
  }
}

locals {
  vpc_cidr               = var.vpc_cidr
  vpc_availability_zones = slice(data.aws_availability_zones.available.names, 0, 3)
}

resource "aws_ebs_encryption_by_default" "ebs-encryption" {
  enabled = true
}

module "aws_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = local.vpc_cidr

  azs             = local.vpc_availability_zones
  private_subnets = [for k, v in local.vpc_availability_zones : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.vpc_availability_zones : cidrsubnet(local.vpc_cidr, 8, k + 48)]

  private_subnet_tags = {
    type = "private"
  }

  public_subnet_tags = {
    type = "public"
  }

  create_database_subnet_group = false

  enable_nat_gateway = true
  enable_vpn_gateway = true
  single_nat_gateway = true
}

