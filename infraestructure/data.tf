data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

#if you want to use an existed kms keys 

data "aws_kms_key" "ec2" {
  key_id = "alias/aws/ec2"
}

data "aws_kms_key" "s3" {
  key_id = "alias/aws/ec2"
}