module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = "hometask-vpc"
  cidr = "10.30.0.0/16"

  azs              = ["${var.region}a", "${var.region}b", "${var.region}c"]
  private_subnets  = ["10.30.1.0/24", "10.30.2.0/24", "10.30.3.0/24"]
  public_subnets   = ["10.30.101.0/24", "10.30.102.0/24", "10.30.103.0/24"]
  database_subnets = ["10.30.201.0/24", "10.30.202.0/24", "10.30.203.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = false
  map_public_ip_on_launch = true
  enable_dns_hostnames = true
  enable_dns_support   = true

}