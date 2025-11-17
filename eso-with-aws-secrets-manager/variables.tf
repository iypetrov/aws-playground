locals {
  name        = "eks-secrets-example"
  vpc_cidr    = "10.0.0.0/16"
  k8s_version = "1.34"
}

variable "aws_access_key_id" {
  type      = string
  sensitive = true
}

variable "aws_secret_access_key" {
  type      = string
  sensitive = true
}

variable "aws_region" {
  type    = string
  default = "eu-central-1"
}
