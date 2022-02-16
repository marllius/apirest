resource "aws_key_pair" "deployer" {
  key_name   = var.aws_key_pair_deployer
  public_key = var.public_key
}

resource "tls_private_key" "deployer" {
  algorithm   = "RSA"
  ecdsa_curve = "2048"
}