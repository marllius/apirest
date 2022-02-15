locals {
  postgresql_cluster = {
    pg-node1 = {
      instance_type     = var.instance_type
      availability_zone = element(module.vpc.azs, 0)
      subnet_id         = element(module.vpc.database_subnets, 0)
      root_block_device = [
        {
          device_name = var.device_name
          volume_type = "gp2"
          volume_size = 8
          encrypted   = true
          tags = {
            block_device = "root-block"
            instance     = "pg-node1"
          }
        }
      ]
      ebs_block_device = [
        {
          device_name = "/dev/sdb"
          volume_type = "gp2"
          volume_size = 8
          encrypted   = true
          kms_key_id  = data.aws_kms_key.ec2.id
          tags = {
            block_device = "pgdata"
            instance     = "pg-node1"
          }
        }
      ]
      user_data_base64 = base64encode(var.user_data)
      key_name         = var.key_name
      tags = {
        instance  = "pg-node1"
        terraform = "true"
      }
    }
    pg-node2 = {
      instance_type     = var.instance_type
      availability_zone = element(module.vpc.azs, 1)
      subnet_id         = element(module.vpc.database_subnets, 1)
      root_block_device = [
        {
          device_name = var.device_name
          volume_type = "gp2"
          volume_size = 8
          encrypted   = true
          tags = {
            block_device = "root-block"
            instance     = "pg-node2"
          }
        }
      ]
      ebs_block_device = [
        {
          device_name = "/dev/sdb"
          volume_type = "gp2"
          volume_size = 8
          encrypted   = true
          kms_key_id  = data.aws_kms_key.ec2.id
          tags = {
            block_device = "pgdata"
            instance     = "pg-node2"
          }
        }
      ]
      user_data_base64 = base64encode(var.user_data)
      key_name         = var.key_name
      tags = {
        instance  = "pg-node2"
        terraform = "true"
      }
    }
    pg-node3 = {
      instance_type     = var.instance_type
      availability_zone = element(module.vpc.azs, 2)
      subnet_id         = element(module.vpc.database_subnets, 2)
      root_block_device = [
        {
          device_name = var.device_name
          volume_type = "gp2"
          volume_size = 8
          encrypted   = true
          tags = {
            block_device = "root-block"
            instance     = "pg-node3"
          }
        }
      ]
      ebs_block_device = [
        {
          device_name = "/dev/sdb"
          volume_type = "gp2"
          volume_size = 8
          encrypted   = true
          kms_key_id  = data.aws_kms_key.ec2.id
          tags = {
            block_device = "pgdata"
            instance     = "pg-node3"
          }
        }
      ]
      user_data_base64 = base64encode(var.user_data)
      key_name         = var.key_name
      tags = {
        instance  = "pg-node3"
        terraform = "true"
      }
    }
  }
}

################################################################################
# EC2 Module - multiple instances with `for_each`
################################################################################

module "postgresql_cluster" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  for_each = local.postgresql_cluster

  name = each.key

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = each.value.instance_type
  availability_zone      = each.value.availability_zone
  subnet_id              = each.value.subnet_id
  vpc_security_group_ids = [module.db_security_group.security_group_id]
  user_data_base64       = each.value.user_data_base64
  key_name               = each.value.key_name

  enable_volume_tags = false
  root_block_device  = lookup(each.value, "root_block_device", [])

  associate_public_ip_address = true

  tags = each.value.tags
}
