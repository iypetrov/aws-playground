output "corex_secret_arns" {
  value = data.aws_secretsmanager_secrets.corex_secrets.arns
}

output "corex_secret_names" {
  value = data.aws_secretsmanager_secrets.corex_secrets.names
}
