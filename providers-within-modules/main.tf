terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  alias  = "euw2"
  region = "eu-west-2"
}

provider "aws" {
  alias  = "usw2"
  region = "us-west-2"
}

module "network" {
  source = "./modules/network"
  providers = {
    aws = aws.usw2
  }
  network_cfg = {
    aws_vpc_cidr              = "10.0.0.0/16"
    aws_public_subnet_a_cidr  = "10.0.1.0/24"
    aws_private_subnet_a_cidr = "10.0.2.0/24"
  }
}
