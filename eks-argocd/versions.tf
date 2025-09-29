terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.14.1"
    }
    gitsync = {
      source  = "ip812/gitsync"
      version = "1.0.0"
    }
  }
}
