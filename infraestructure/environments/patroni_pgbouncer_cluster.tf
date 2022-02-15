locals {
  patroni_pgbouncer_cluster = {
    patroni-pgbouncer-node1 = {
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
            instance     = "patroni-pgbouncer-node1"
          }
        }
      ]
      user_data_base64 = base64encode(var.user_data)
      key_name         = var.key_name
      tags = {
        instance  = "patroni-pgbouncer-node1"
        terraform = "true"
      }
    }
    patroni-pgbouncer-node2 = {
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
            instance     = "patroni-pgbouncer-node2"
          }
        }
      ]
      user_data_base64 = base64encode(var.user_data)
      key_name         = var.key_name
      tags = {
        instance  = "patroni-pgbouncer-node2"
        terraform = "true"
      }
    }
    patroni-pgbouncer-node3 = {
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
            instance     = "patroni-pgbouncer-node3"
          }
        }
      ]
      user_data_base64 = base64encode(var.user_data)
      key_name         = var.key_name
      tags = {
        instance  = "patroni-pgbouncer-node3"
        terraform = "true"
      }
    }
  }
}

################################################################################
# EC2 Module - multiple instances with `for_each`
################################################################################

module "patroni_pgbouncer_cluster" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  for_each = local.patroni_pgbouncer_cluster

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
