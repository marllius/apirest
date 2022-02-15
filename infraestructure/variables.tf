variable "region" {
  description = "The region where the object will be created."
  type        = string
  default     = "us-east-1"
}

variable "region" {
  description = "The region where s3 replication cross region will be created."
  type        = string
  default     = "us-weast-1"
}

variable "delimiter" {
  type    = string
  default = "-"
}

variable "instance_db_name" {
  description = "The name for composite ec2 instances"
  type        = string
  default     = "PostgreSQL"
}

variable "instance_type" {
  description = "The instance type will be create"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "The name ssh key on AWS"
  type        = string
  default     = "marlliusribeiro-zoop-infralab-rsa"  
}

variable "public_key" {
  description = "The public key material."
  type        = string
  default     = ""
}

variable "user_data" {
  description = "The default instalation on ec2 instance"
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
  description = "he device name to expose to the instance (for example, /dev/sdh or xvdh). if you choose a sdh or nvme will use a diffent kind of virutalization"
  type        = string
  default     = "/dev/sda"  
}

