data "aws_secretsmanager_secrets" "corex_secrets" {
  filter {
    name   = "tag-key"
    values = ["ManagedBy"]
  }

  filter {
    name   = "tag-value"
    values = ["ip812"]
  }
}
