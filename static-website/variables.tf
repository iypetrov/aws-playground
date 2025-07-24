data "aws_caller_identity" "current" {}

variable "aws_region" {
  type    = string
  default = "eu-west-2"
}

variable "domain_name" {
  type    = string
  default = "ip812.click"
}

variable "zone_id" {
  type    = string
  default = "Z0701329ZBXDJ0CZIFW4"
}
