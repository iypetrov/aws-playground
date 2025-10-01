resource "gitsync_values_yaml" "argocd" {
  branch  = "master"
  path    = "gasx/argocd/values.yaml"
  content = <<EOT
name: foo
redis:
  primary_endpoint_address: ${module.elasticache.replication_group_primary_endpoint_address}
  port: ${module.elasticache.replication_group_port}
stuff:
  name: dge
EOT
}
