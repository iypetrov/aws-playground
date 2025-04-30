terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
}

resource "aws_iam_user" "container_user" {
  name = "CONTAINER_USER"
}

data "aws_iam_policy_document" "container_document" {
  statement {
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = ["*"]
    effect    = "Allow"
  }

  statement {
    actions = [
      "ecr:DescribeRepositories",
      "ecr:CreateRepository",
      "ecr:BatchCheckLayerAvailability",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
      "ecr:BatchGetImage"
    ]
    resources = [
      "arn:aws:ecr:eu-west-2:678468774710:repository/*"
    ]
    effect = "Allow"
  }
}

resource "aws_iam_user_policy" "container_policy" {
  name   = "Container-Access"
  user   = aws_iam_user.container_user.name
  policy = data.aws_iam_policy_document.container_document.json
}

resource "aws_iam_access_key" "container_user_key" {
  user = aws_iam_user.container_user.name
}

output "access_key_id" {
  value = aws_iam_access_key.container_user_key.id
}

output "secret_access_key" {
  value     = aws_iam_access_key.container_user_key.secret
  sensitive = true
}
