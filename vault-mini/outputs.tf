output "website_url" {
  value = "https://${local.subdomain_name}.${var.domain_name}/${local.env}"
}
