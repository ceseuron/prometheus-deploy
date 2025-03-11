output "vpc_name" {
  value = var.vpc_name
}

output "vpc_id" {
  value = module.aws_vpc.vpc_id
}

output "vpc_cidr" {
  value = var.vpc_cidr
}

output "vpc_arn" {
  value = module.aws_vpc.vpc_arn
}

output "private_subnets" {
  value = module.aws_vpc.private_subnets
}

output "public_subnets" {
  value = module.aws_vpc.public_subnets
}

