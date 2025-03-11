provider "aws" {
  region              = "us-east-2"
  allowed_account_ids = [var.aws_account_id]
  profile             = "default"

  assume_role {
    role_arn = "arn:aws:iam::757570189880:role/prometheus-deploy"
  }
}
