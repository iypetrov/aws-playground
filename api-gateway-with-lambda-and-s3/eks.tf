resource "aws_vpc_endpoint" "eks" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.${local.aws_region}.eks"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [aws_subnet.private_subnet_a.id]
  security_group_ids = [aws_security_group.lambda_sg.id]
  private_dns_enabled = true
}
