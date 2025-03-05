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

resource "aws_subnet" "subnet" {
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
  depends_on     = [aws_subnet.subnet, aws_route_table.rt]
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_security_group" "backend_security_group" {
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
  name               = "role"
  assume_role_policy = file("assume_role_policy.json")
}

resource "aws_iam_role_policy_attachment" "role_policy_attachment" {
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_instance_profile" "profile" {
  name = "profile"
  role = aws_iam_role.role.name
}

resource "aws_instance" "vm" {
  ami                    = "ami-07c1b39b7b3d2525d"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.subnet.id
  vpc_security_group_ids = [aws_security_group.backend_security_group.id]
  iam_instance_profile   = aws_iam_instance_profile.profile.name
  user_data              = file("setup.sh")
  tags = {
    Owner = var.owner
  }
}

output "instance_public_ip" {
  description = "The public IP of the EC2 instance"
  value       = aws_instance.vm.public_ip
}
