#region to deploy
region         = "us-east-1"
replica_region = "us-weast-1"

#vpc configuration
private_subnets         = ["10.30.1.0/24", "10.30.2.0/24", "10.30.3.0/24"]
public_subnets          = ["10.30.101.0/24", "10.30.102.0/24", "10.30.103.0/24"]
public_subnets          = ["10.30.201.0/24", "10.30.202.0/24", "10.30.203.0/24"]
cidr                    = "10.30.0.0/16"
enable_nat_gateway      = true
enable_vpn_gateway      = false
map_public_ip_on_launch = true
enable_dns_hostnames    = true
enable_dns_support      = true
vpc_name                = "hometask-vpc"

#encrypt keys for instances
data_aws_kms_key      = ""
public_key            = ""
aws_key_pair_deployer = ""
key_name              = ""

#s3 configuration
replication_time_minutes = 15

#ec2 configuration
instance_type        = "t2.micro"
instance_db_name     = "PostgreSQL"
instance_type        = "t2.micro"
device_name          = "/dev/sda"
app_volume_size      = "8"
balancer_volume_size = "8"
db_volume_size       = "8"
etcd_volume_size     = "8"
volume_type          = "gp2"

user_data = <<-EOT
  #!/bin/bash

  export PATH=$PATH:/usr/bin

  sudo apt-get update

  sudo apt-get install -y vim htop build-essential \
  libssl-dev libffi-dev net-tools \
  python3-dev python3-pip python-setuptools \
  gnupg apt-transport-https curl git

EOT