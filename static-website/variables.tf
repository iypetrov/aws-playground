data "aws_caller_identity" "current" {}

variable "aws_region" {
  type    = string
  default = "eu-west-2"
}
