module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = var.vpc_name
  cidr = var.cidr

  azs              = ["${var.region}a", "${var.region}b", "${var.region}c"]
  private_subnets  = [var.private_subnets]
  public_subnets   = [var.public_subnets]
  database_subnets = [var.database_subnets]

  enable_nat_gateway      = var.enable_nat_gateway
  enable_vpn_gateway      = var.enable_vpn_gateway
  map_public_ip_on_launch = var.map_public_ip_on_launch
  enable_dns_hostnames    = var.enable_dns_hostnames
  enable_dns_support      = var.enable_dns_support

}