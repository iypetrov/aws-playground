locals {
  name           = "api"
  env            = "prod"
  vpc_cidr       = "10.1.0.0/16"
  aws_region     = "eu-central-1"
  subdomain_name = "secrets"
}

variable "aws_access_key_id" {
  type      = string
  sensitive = true
}

variable "aws_secret_access_key" {
  type      = string
  sensitive = true
}

variable "zone_id" {
  type = string
}

variable "domain_name" {
  type = string
}
