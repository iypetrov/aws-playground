terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

variable "network_cfg" {
  type = object({
    aws_vpc_cidr            = string
    aws_public_subnet_a_cidr = string
    aws_private_subnet_a_cidr = string
  })
}

data "aws_region" "current" {}

resource "aws_vpc" "vpc" {
  cidr_block = var.network_cfg.aws_vpc_cidr
  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.network_cfg.aws_public_subnet_a_cidr
  availability_zone       = "${data.aws_region.current.name}a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private_subnet_a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.network_cfg.aws_private_subnet_a_cidr
  availability_zone       = "${data.aws_region.current.name}a"
}
