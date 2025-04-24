resource "aws_ecr_repository" "foo_ecr_repository" {
  name                 = "playground/foo"
  image_tag_mutability = "MUTABLE"
}

resource "aws_iam_user" "ecr_user" {
  name = "ecr-full-access-user"
}

resource "aws_iam_policy" "ecr_repo_policy" {
  name        = "ECRFullAccessToSpecificRepo"
  description = "Grants full access to ECR repository"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "ecr:*"
        ],
        Resource = "*" 
      },
      {
        Effect   = "Allow",
        Action   = [
          "ecr:GetAuthorizationToken"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "ecr_policy_attach" {
  user       = aws_iam_user.ecr_user.name
  policy_arn = aws_iam_policy.ecr_repo_policy.arn
}

resource "aws_iam_access_key" "ecr_user_key" {
  user = aws_iam_user.ecr_user.name
}

output "ecr_user_access_key_id" {
  value = aws_iam_access_key.ecr_user_key.id
}

output "ecr_user_secret_access_key" {
  value     = aws_iam_access_key.ecr_user_key.secret
  sensitive = true
}
