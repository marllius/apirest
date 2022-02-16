variable "region" {
  description = "The region where the all resources will be created."
  type        = string
  default     = "us-east-1"
}

variable "replica_region" {
  description = "The region where s3 replication cross region will be created."
  type        = string
  default     = "us-weast-1"
}

variable "instance_db_name" {
  description = "The name for composite ec2 instances"
  type        = string
  default     = "PostgreSQL"
}

variable "instance_type" {
  description = "The instance type will be create, all instances use this configuration"
  type        = string
  default     = "t2.micro"
}

variable "user_data" {
  description = "The default instalation on ec2 instance, all ec2 instances use that"
  type        = string
  default     = <<-EOT
  #!/bin/bash

  export PATH=$PATH:/usr/bin

  sudo apt-get update

  sudo apt-get install -y vim htop build-essential \
  libssl-dev libffi-dev net-tools \
  python3-dev python3-pip python-setuptools \
  gnupg apt-transport-https curl git

  EOT
}

variable "device_name" {
  description = "The device name to expose to the instance (for example, /dev/sdh or xvdh). if you choose a sdh or nvme will use a diffent kind of virutalization"
  type        = string
  default     = "/dev/sda"
}

variable "app_volume_size" {
  description = "The size disk for all application instances"
  type        = number
  default     = "8"
}

variable "balancer_volume_size" {
  description = "The size disk for all balancers instances"
  type        = number
  default     = "8"
}

variable "db_volume_size" {
  description = "The size disk for all databases instances"
  type        = number
  default     = "8"
}

variable "etcd_volume_size" {
  description = "The size disk for all etcd instances"
  type        = number
  default     = "8"
}

variable "private_subnets" {
  description = "The size disk for all etcd instances"
  type        = list(string)
  default     = ["10.30.1.0/24", "10.30.2.0/24", "10.30.3.0/24"]
}

variable "public_subnets" {
  description = "The size disk for all etcd instances"
  type        = list(string)
  default     = ["10.30.101.0/24", "10.30.102.0/24", "10.30.103.0/24"]
}

variable "public_subnets" {
  description = "The size disk for all etcd instances"
  type        = list(string)
  default     = ["10.30.201.0/24", "10.30.202.0/24", "10.30.203.0/24"]
}

variable "cidr" {
  description = "the cidr block for you vpc"
  type        = string
  default     = "10.30.0.0/16"
}

variable "enable_nat_gateway" {
  description = "to enable nat gateway on vpc"
  type        = bool
  default     = true
}

variable "enable_vpn_gateway" {
  description = "to enable vpn gateway on vpc"
  type        = bool
  default     = false
}

variable "map_public_ip_on_launch" {
  type    = bool
  default = true
}

variable "enable_dns_hostnames" {
  description = "Whether or not the VPC has DNS hostname support"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "A boolean flag to enable/disable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "vpc_name" {
  description = "The size disk for all etcd instances"
  type        = string
  default     = "hometask-vpc"
}

locals {
  bucket_name             = "pgbackup-origin-${random_pet.this.id}"      #will add a random pet names for the name
  destination_bucket_name = "pgbackup-replication-${random_pet.this.id}" #will add a random  pet names for the name

  key_name = var.data_aws_kms_key_ec2 != "" ? data.aws_kms_key.deploy : (var.aws_key_pair_deployer == "" || var.public_key == "" ? tls_private_key.deployer : var.aws_key_pair_deployer)
}


variable "volume_type" {
  description = "The size disk for all etcd instances"
  type        = string
  default     = "gp2"
}

#Setting this variable when you want to use your previus kms keys.


variable "data_aws_kms_key" {
  description = "the ssh key to use on all ec2 instances, using alias name e.g `alias/aws/ec2`"
  type        = string
  default     = ""
}

#Setting this variables when you want to generate a new key, you can pass you public ssh-key here

variable "public_key" {
  description = "The public key material. e.g `ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 email@example.com`"
  type        = string
  default     = ""
}

variable "aws_key_pair_deployer" {
  description = "The name for your ssh key"
  type        = string
  default     = ""
}

variable "key_name" {
  description = "The name ssh key on AWS"
  type        = string
  default     = ""
}



minutes = var.replication_time_minutes #15
