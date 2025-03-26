resource "aws_security_group" "vm_sg" {
  vpc_id = aws_vpc.vpc.id
  ingress = [
    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "everything"
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = -1
      security_groups  = []
      self             = false
      to_port          = 0
    }
  ]
  egress = [
    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "everything"
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = -1
      security_groups  = []
      self             = false
      to_port          = 0
    }
  ]

  timeouts {
    delete = "2m"
  }
}
resource "aws_iam_role" "vm_role" {
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

resource "aws_iam_role_policy_attachment" "vm_role_policy_attachment" {
  role       = aws_iam_role.vm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_instance_profile" "vm_profile" {
  name = "profile"
  role = aws_iam_role.vm_role.name
}

resource "aws_instance" "vm_a" {
  ami                         = "ami-07c1b39b7b3d2525d"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet_a.id
  vpc_security_group_ids      = [aws_security_group.vm_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.vm_profile.name
  user_data_replace_on_change = true
  user_data                   = <<-EOF
    #!/bin/bash
    apt-get update
    apt install -y git python3 python3-pip python3.12-venv
    ln -sf python3 /usr/bin/python
    python -m venv ci
    . ci/bin/activate
    git clone https://github.com/iypetrov/debug-display-req-headers.git
    cd debug-display-req-headers
    pip3 install -r requirements.txt
    python3 main.py
  EOF

  lifecycle {
    replace_triggered_by = [
      aws_security_group.vm_sg.name,
      aws_security_group.vm_sg.ingress,
      aws_security_group.vm_sg.egress
    ]
  }
}

resource "aws_instance" "vm_b" {
  ami                         = "ami-07c1b39b7b3d2525d"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet_b.id
  vpc_security_group_ids      = [aws_security_group.vm_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.vm_profile.name
  user_data_replace_on_change = true
  user_data                   = <<-EOF
    #!/bin/bash
    apt-get update
    apt install -y git python3 python3-pip python3.12-venv
    ln -sf python3 /usr/bin/python
    python -m venv ci
    . ci/bin/activate
    git clone https://github.com/iypetrov/debug-display-req-headers.git
    cd debug-display-req-headers
    pip3 install -r requirements.txt
    python3 main.py
  EOF

  lifecycle {
    replace_triggered_by = [
      aws_security_group.vm_sg.name,
      aws_security_group.vm_sg.ingress,
      aws_security_group.vm_sg.egress
    ]
  }
}
