
# Get availability zones for the currently defined region.
data "aws_availability_zones" "available" {
  state = "available"

  filter {
    name   = "region-name"
    values = [var.aws_region]
  }
}

data "aws_ami" "image_info" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

data "aws_secretsmanager_secret" "ssh_secret_id" {
  name = var.aws_secret_name
}

data "aws_secretsmanager_secret_version" "ssh_secret" {
  secret_id = data.aws_secretsmanager_secret.ssh_secret_id.id
}

locals {
  spot_price  = var.aws_ec2_create_spot_instance == true ? var.aws_ec2_spot_price : null
  spot_type   = var.aws_ec2_create_spot_instance == true ? var.aws_ec2_spot_type : null
  secret_data = jsondecode(data.aws_secretsmanager_secret_version.ssh_secret.secret_string)
}

resource "aws_key_pair" "ec2_keypair" {
  key_name   = "ec2-ssh-key"
  public_key = local.secret_data["public_key"]
}

resource "aws_security_group" "prometheus_sg" {
  vpc_id      = var.aws_vpc_id
  name        = "prometheus-sg"
  description = "Prometheus security group."

  # Inbound rules
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rules
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  count = var.instance_count

  name = "${var.aws_ec2_name}-${count.index}"

  create_spot_instance = var.aws_ec2_create_spot_instance
  spot_price           = local.spot_price
  spot_type            = local.spot_type

  instance_type               = var.aws_ec2_instance_type
  ami                         = data.aws_ami.image_info.image_id
  key_name                    = aws_key_pair.ec2_keypair.key_name
  monitoring                  = true
  vpc_security_group_ids      = [aws_security_group.prometheus_sg.id]
  subnet_id                   = var.public_subnets[0]
  associate_public_ip_address = true

  root_block_device = [{
    volume_type           = var.aws_ec2_disk_type
    volume_size           = var.aws_ec2_disk_size
    delete_on_termination = var.aws_ec2_disk_delete_on_terminate
  }]

  tags = {
    terraform   = "true"
    environment = "test"
    application = "prometheus"
    role        = count.index == 0 ? "primary" : "secondary"
  }
}
