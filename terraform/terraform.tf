terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.0"
    }
  }
  backend "s3" {
    bucket  = "ceseuron-terraform"
    profile = "default"
    key     = "prometheus-deploy/terraform.tfstate"
    region  = "us-east-2"

    assume_role = {
      role_arn = "arn:aws:iam::757570189880:role/prometheus-deploy"
    }
  }
}
