resource "gitsync_values_yaml" "argocd" {
  branch  = "master"
  path    = "gasx/argocd/values.yaml"
  content = <<EOT
name: foo
stuff:
  name: dge
EOT
}
