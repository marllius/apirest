module "pgbackrest" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "pgbackrest-server"

  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  availability_zone           = element(module.vpc.azs, 0)
  subnet_id                   = element(module.vpc.private_subnets, 0)
  vpc_security_group_ids      = [module.db_security_group.security_group_id]
  associate_public_ip_address = true
  user_data_base64            = base64encode(var.user_data)
  enable_volume_tags          = false
  key_name                    = var.key_name

  root_block_device = [
    {
      volume_type = "gp2"
      volume_size = 8
      encrypted   = true
      kms_key_id  = data.aws_kms_key.ec2.id
      tags = {
        block_device = "root-block"
        instance     = "pgbackrest-server"
      }
    },
  ]

  ebs_block_device = [
    {
      device_name = "/dev/sdb"
      volume_type = "gp2"
      volume_size = 8
      encrypted   = true
      kms_key_id  = data.aws_kms_key.ec2.id
    }
  ]

  tags = {
    instance  = "pgbackrest-server"
    terraform = "true"
  }
}