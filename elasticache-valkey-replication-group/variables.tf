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

variable "elasticache_auth_token" {
  type      = string
  sensitive = true
}
