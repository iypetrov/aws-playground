resource "aws_security_group" "db_sg" {
  vpc_id = aws_vpc.vpc.id
  ingress = [
    {
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
  ]
  egress = [
    {
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
  ]
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "foo-db-subnet-group"
  subnet_ids = [aws_subnet.sb_a.id, aws_subnet.sb_b.id]
}

resource "aws_db_instance" "db" {
  allocated_storage                     = 20
  engine                                = "oracle-se2"
  engine_version                        = "19.0.0.0.ru-2022-10.rur-2022-10.r1"
  identifier                            = "foo"
  instance_class                        = "db.t3.small"
  db_subnet_group_name                  = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids                = [aws_security_group.db_sg.id]
  storage_encrypted                     = false
  publicly_accessible                   = true
  delete_automated_backups              = false
  skip_final_snapshot                   = true
  username                              = "test1234"
  password                              = "test1234"
  apply_immediately                     = true
  multi_az                              = false
  iam_database_authentication_enabled   = false
  license_model                         = "license-included"
}
