resource "gitsync_values_yaml" "example" {
  branch  = "master"
  path    = "values/values.yaml"
  content = <<EOT
name: bar
replicas: 2
EOT
}
