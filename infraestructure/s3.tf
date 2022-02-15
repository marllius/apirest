locals {
  bucket_name             = "pgbackup-origin-${random_pet.this.id}"
  destination_bucket_name = "pgbackup-replication-${random_pet.this.id}"
}

data "aws_caller_identity" "current" {}

resource "random_pet" "this" {
  length = 2
}

module "replica_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  providers = {
    aws = aws.replica
  }

  bucket = local.destination_bucket_name
  acl    = "private"

  versioning = {
    enabled = true
  }
}

module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = local.bucket_name
  acl    = "private"

  versioning = {
    enabled = true
  }

  replication_configuration = {
    role = aws_iam_role.replication.arn

    rules = [
      {
        id       = "something-with-kms-and-filter"
        status   = "Enabled"
        priority = 10

        source_selection_criteria = {
          sse_kms_encrypted_objects = {
            enabled = true
          }
        }

        filter = {
          prefix = "one"
          tags = {
            ReplicateMe = "Yes"
          }
        }

        destination = {
          bucket             = "arn:aws:s3:::${local.destination_bucket_name}"
          storage_class      = "STANDARD"
          replica_kms_key_id = aws_kms_key.replica.arn
          account_id         = data.aws_caller_identity.current.account_id
          access_control_translation = {
            owner = "Destination"
          }
          replication_time = {
            status  = "Enabled"
            minutes = var.replication_time_minutes #15
          }
          metrics = {
            status  = "Enabled"
            minutes = 15
          }
        }
      },
      {
        id       = "something-with-filter"
        status   = "Enabled"
        priority = 20

        filter = {
          prefix = "two"
          tags = {
            ReplicateMe = "Yes"
          }
        }

        destination = {
          bucket        = "arn:aws:s3:::${local.destination_bucket_name}"
          storage_class = "STANDARD"
        }
      },
      {
        id       = "everything-with-filter"
        status   = "Enabled"
        priority = 30

        filter = {
          prefix = ""
        }

        destination = {
          bucket        = "arn:aws:s3:::${local.destination_bucket_name}"
          storage_class = "STANDARD"
        }
      },
      {
        id     = "everything-without-filters"
        status = "Enabled"

        destination = {
          bucket        = "arn:aws:s3:::${local.destination_bucket_name}"
          storage_class = "STANDARD"
        }
      },
    ]
  }

}