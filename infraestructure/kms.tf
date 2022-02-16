#create kms keys

resource "aws_kms_key" "s3" {
  provider = aws.replica

  description = "Backup postgresql cluster to S3 bucket replication"
}

resource "aws_kms_key" "pg" {
  provider = aws.replica

  description = "EBS datatabases"
}
