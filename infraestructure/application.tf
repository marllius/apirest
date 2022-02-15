locals {
  user_data_primary = <<-EOT
  #!/bin/bash
  echo "Hello Terraform!"
  EOT

  user_data_replica = <<-EOT
  #!/bin/bash
  echo "Hello Terraform!"
  EOT

  tags = {
    terraform   = "true"
    Environment = "hometask"
  }

  multiple_instances = {
    primary = {
      instance_type     = "t3.small"
      availability_zone = element(module.vpc.azs, 0)
      subnet_id         = element(module.vpc.database_subnets, 0)
      root_block_device = [
        {
          encrypted   = true
          volume_type = "gp3"
          throughput  = 200
          volume_size = 50
          tags = {
            Name = "my-root-block"
          }
        }
      ]
      ebs_block_device = [
        {
          device_name = "/dev/sdb"
          volume_type = "gp3"
          volume_size = 5
          throughput  = 200
          encrypted   = true
          kms_key_id  = data.aws_kms_key.ec2.id
          tags = {
            Name       = trimspace(join(var.delimiter, [var.name, "primary"]))
            tablespace = "data"
          }
        }
      ]
      ebs_block_device = [
        {
          device_name = "/dev/sdc"
          volume_type = "gp3"
          volume_size = 5
          throughput  = 200
          encrypted   = true
          kms_key_id  = data.aws_kms_key.ec2.id
          tags = {
            Name       = trimspace(join(var.delimiter, [var.name, "primary"]))
            tablespace = "index"
          }
        }
      ]
      user_data_base64 = base64encode(local.user_data_primary)
    }
    replica-one = {
      instance_type     = "t3.small"
      availability_zone = element(module.vpc.azs, 1)
      subnet_id         = element(module.vpc.database_subnets, 1)
      root_block_device = [
        {
          encrypted   = true
          volume_type = "gp3"
          throughput  = 200
          volume_size = 50
        }
      ]
      ebs_block_device = [
        {
          device_name = "/dev/sdb"
          volume_type = "gp3"
          volume_size = 5
          throughput  = 200
          encrypted   = true
          kms_key_id  = data.aws_kms_key.ec2.id
          tags = {
            Name       = trimspace(join(var.delimiter, [var.name, "replica-one"]))
            tablespace = "data"
          }
        }
      ]
      ebs_block_device = [
        {
          device_name = "/dev/sdc"
          volume_type = "gp3"
          volume_size = 5
          throughput  = 200
          encrypted   = true
          kms_key_id  = data.aws_kms_key.ec2.id
          tags = {
            Name       = trimspace(join(var.delimiter, [var.name, "replica-one"]))
            tablespace = "index"
          }
        }
      ]
      user_data_base64 = base64encode(local.user_data_replica)
    }
    replica-two = {
      instance_type     = "t3.small"
      availability_zone = element(module.vpc.azs, 2)
      subnet_id         = element(module.vpc.database_subnets, 2)
      root_block_device = [
        {
          encrypted   = true
          volume_type = "gp3"
          volume_size = 50
          tags = {
            Name = "my-root-block"
          }
        }
      ]
      ebs_block_device = [
        {
          device_name = "/dev/sdb"
          volume_type = "gp3"
          volume_size = 5
          throughput  = 200
          encrypted   = true
          kms_key_id  = data.aws_kms_key.ec2.id
          tags = {
            Name       = trimspace(join(var.delimiter, [var.name, "replica-two"]))
            tablespace = "data"
          }
        }
      ]
      ebs_block_device = [
        {
          device_name = "/dev/sdc"
          volume_type = "gp3"
          volume_size = 5
          throughput  = 200
          encrypted   = true
          kms_key_id  = data.aws_kms_key.ec2.id
          tags = {
            Name       = trimspace(join(var.delimiter, [var.name, "replica-two"]))
            tablespace = "index"
          }
        }
      ]
      user_data_base64 = base64encode(local.user_data_replica)
    }
  }
}

################################################################################
# EC2 Module - multiple instances with `for_each`
################################################################################

module "ec2_multiple" {
  source = "../../"

  for_each = local.multiple_instances

  name = trimspace(join("", [var.name, var.delimiter, each.key]))

  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = each.value.instance_type
  availability_zone      = each.value.availability_zone
  subnet_id              = each.value.subnet_id
  vpc_security_group_ids = [module.security_group.security_group_id]
  user_data_base64       = each.value.user_data_base64

  enable_volume_tags = true
  root_block_device  = lookup(each.value, "root_block_device", [])

  tags = local.tags
}
