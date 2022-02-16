module "db_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "pg-sg"
  description = "Security group for PostgreSQL EC2 instance"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = [var.cidr]
  ingress_rules       = ["http-80-tcp", "postgresql-tcp"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 8008
      to_port     = 8008
      protocol    = "tcp"
      description = "patroni"
      cidr_blocks = var.cidr
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "ssh"
      cidr_blocks = "0.0.0.0/0" #var.cidr
    },
  ]
  egress_rules = ["all-all"]

}

module "app_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "app-sg"
  description = "default securty group for app"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "api"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "ssh"
      cidr_blocks = "0.0.0.0/0" #var.cidr
    },
  ]
  egress_rules = ["all-all"]

}

module "app_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "etcd-sg"
  description = "default securtiy group for etcd"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 2379
      to_port     = 2379
      protocol    = "tcp"
      description = "etcd-1"
      cidr_blocks = var.cidr
    },
    {
      from_port   = 2380
      to_port     = 2380
      protocol    = "tcp"
      description = "etcd-2"
      cidr_blocks = var.cidr
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "ssh"
      cidr_blocks = var.cidr
    },
  ]
  egress_rules = ["all-all"]

}