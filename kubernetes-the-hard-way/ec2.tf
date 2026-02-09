locals {
  nodes = [
    {
      name          = "jumpbox"
      description   = "Administration host"
      ami           = "ami-00ebb2b898eebe380" # Debian Linux 13
      instance_type = "t3.micro"
      storage_size  = 10
      user_data    = <<-EOF
        #!/bin/bash
        apt-get update
        apt-get -y install wget curl vim openssl git
        git clone --depth 1 https://github.com/kelseyhightower/kubernetes-the-hard-way.git /kubernetes-the-hard-way
      EOF
    },
    {
      name          = "server"
      description   = "Kubernetes server"
      ami           = "ami-00ebb2b898eebe380" # Debian Linux 13
      instance_type = "t3.small"
      storage_size  = 20
      user_data    = <<-EOF
        #!/bin/bash
        apt-get update
        apt-get -y install wget curl vim openssl git
      EOF
    },
    {
      name          = "node-0"
      description   = "Kubernetes worker node"
      ami           = "ami-00ebb2b898eebe380" # Debian Linux 13
      instance_type = "t3.small"
      storage_size  = 20
      user_data    = <<-EOF
        #!/bin/bash
        apt-get update
        apt-get -y install wget curl vim openssl git
      EOF
    },
    {
      name          = "node-1"
      description   = "Kubernetes worker node"
      ami           = "ami-00ebb2b898eebe380" # Debian Linux 13
      instance_type = "t3.small"
      storage_size  = 20
      user_data    = <<-EOF
        #!/bin/bash
        apt-get update
        apt-get -y install wget curl vim openssl git
      EOF
    }
  ]
}

resource "aws_security_group" "this" {
  vpc_id = aws_vpc.vpc.id

  timeouts {
    delete = "2m"
  }
}

resource "aws_vpc_security_group_egress_rule" "egress" {
  security_group_id = aws_security_group.this.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = -1
}

resource "aws_iam_role" "this" {
  name = "role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_instance_profile" "this" {
  name = "profile"
  role = aws_iam_role.this.name
}

resource "aws_instance" "this" {
  for_each                    = { for node in local.nodes : node.name => node }
  ami                         = each.value.ami
  instance_type               = each.value.instance_type
  subnet_id                   = aws_subnet.public_subnet_a.id
  vpc_security_group_ids      = [aws_security_group.this.id]
  iam_instance_profile        = aws_iam_instance_profile.this.name
  user_data_replace_on_change = true
  user_data                   = each.value.user_data

  root_block_device {
    iops        = 3000
    volume_size = each.value.storage_size
    volume_type = "gp3"
  }

  tags = {
    Name = each.value.name
    Description = each.value.description
  }

  lifecycle {
    replace_triggered_by = [
      aws_security_group.this.name,
      aws_security_group.this.egress.security_group_rule_id
    ]
  }
}
