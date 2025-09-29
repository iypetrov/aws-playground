locals {
  elasticache_name = "elasticache-argocd"
  elasticache_engine = "valkey"
  elasticache_engine_version = "7.2"
}

module "elasticache" {
  source  = "terraform-aws-modules/elasticache/aws"
  version = "1.9.0"

  replication_group_id    = local.elasticache_name
  replicas_per_node_group = 2

  engine         = local.elasticache_engine
  engine_version = local.elasticache_engine_version
  node_type      = "cache.t4g.small"

  transit_encryption_enabled = true
  auth_token                 = var.elasticache_auth_token
  maintenance_window         = "sun:05:00-sun:09:00"
  apply_immediately          = true

  vpc_id = module.vpc.vpc_id
  security_group_rules = {
    ingress_vpc = {
      description = "VPC traffic"
      cidr_ipv4   = module.vpc.vpc_cidr_block
    }
  }

  subnet_group_name        = local.elasticache_name
  subnet_group_description = "Valkey replication group subnet group"
  subnet_ids               = module.vpc.elasticache_subnets

  create_parameter_group      = true
  parameter_group_name        = local.elasticache_name
  parameter_group_family      = "valkey7"
  parameter_group_description = "Valkey replication group parameter group"
  parameters = [
    {
      name  = "latency-tracking"
      value = "yes"
    }
  ]

  tags = {
    Name = local.elasticache_name
  }
}
