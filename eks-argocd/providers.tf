provider "aws" {
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
  region     = var.aws_region
}

provider "gitsync" {
  url   = "https://github.com/iypetrov/aws-playground.git"
  token = var.github_token
}

provider "gitsync" {
  alias = "poc"
  url   = "https://github.com/iypetrov/aws-playground.git"
  token = var.github_token
}
