terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
}

variable "owner" {
  type    = string
  default = "Ilia Petrov"
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Owner = var.owner
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Owner = var.owner
  }
}

resource "aws_subnet" "sb" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-2a"
  map_public_ip_on_launch = true
  tags = {
    Owner = var.owner
  }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Owner = var.owner
  }
}

resource "aws_route_table_association" "rt_association" {
  depends_on     = [aws_subnet.sb, aws_route_table.rt]
  subnet_id      = aws_subnet.sb.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.vpc.id
  ingress = [
    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "ssh"
      from_port        = 22
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 22
    }
  ]
  egress {
    cidr_blocks      = ["0.0.0.0/0"]
    description      = ""
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = -1
    security_groups  = []
    self             = false
    to_port          = 0
  }
  tags = {
    Owner = var.owner
  }
}

resource "aws_iam_role" "role" {
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

resource "aws_iam_role_policy_attachment" "role_policy_attachment" {
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_instance_profile" "profile" {
  name = "profile"
  role = aws_iam_role.role.name
}

### Old VM
data "template_file" "cloudinit_userdata_old_vm" {
  template = file("templates/init.tml")
  vars = {
    owner = var.owner
  }
}

resource "aws_instance" "old_vm" {
  ami                         = "ami-07c1b39b7b3d2525d"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.sb.id
  vpc_security_group_ids      = [aws_security_group.sg.id]
  iam_instance_profile        = aws_iam_instance_profile.profile.name
  user_data_replace_on_change = true
  user_data                   = data.template_file.cloudinit_userdata_old_vm.rendered
  tags = {
    Owner = var.owner
  }
}

### New VM
resource "aws_instance" "new_vm" {
  ami                         = "ami-07c1b39b7b3d2525d"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.sb.id
  vpc_security_group_ids      = [aws_security_group.sg.id]
  iam_instance_profile        = aws_iam_instance_profile.profile.name
  user_data_replace_on_change = true
  user_data                   = templatefile("templates/init.tml", { owner = var.owner })
  tags = {
    Owner = var.owner
  }
}

