variable "aws_access_key_id" {
  type      = string
  sensitive = true
}

variable "aws_secret_access_key" {
  type      = string
  sensitive = true
}

variable "aws_region" {
  type = string
}

variable "vpc_cidr" {
  type    = string
  default = "10.1.0.0/16"
}

variable "private_subnet_a_cidr" {
  type    = string
  default = "10.1.1.0/24"
}

variable "private_subnet_b_cidr" {
  type    = string
  default = "10.1.2.0/24"
}
