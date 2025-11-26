resource "aws_iam_user" "secrets_manager_user" {
  name = "app-secrets-manager-user"
}

data "aws_iam_policy_document" "secrets_manager_document" {
  statement {
    sid    = "SecretsManagerCRUD"
    effect = "Allow"

    actions = [
      "secretsmanager:CreateSecret",
      "secretsmanager:DeleteSecret",
      "secretsmanager:PutSecretValue",
      "secretsmanager:GetSecretValue",
      "secretsmanager:UpdateSecret",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds",
      "secretsmanager:TagResource",
      "secretsmanager:UntagResource"
    ]

    resources = [
      "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:APP*"
    ]
  }
}

resource "aws_iam_user_policy" "secrets_manager_policy" {
  name   = "app-secrets-manager-policy"
  user   = aws_iam_user.secrets_manager_user.name
  policy = data.aws_iam_policy_document.secrets_manager_document.json
}
