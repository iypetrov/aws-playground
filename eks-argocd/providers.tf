provider "aws" {
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
  region     = var.aws_region
}

provider "gitsync" {
  url   = "https://innersource.soprasteria.com/ENER-GXrestricted/infrastructure/apps.git"
  token = var.gitlab_token
}
