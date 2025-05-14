data "aws_caller_identity" "current" {}

resource "aws_inspector2_enabler" "example" {
  account_ids    = [data.aws_caller_identity.current.account_id]
  resource_types = ["ECR"]
}
