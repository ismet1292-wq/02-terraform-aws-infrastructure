resource "aws_vpc" "demo" {
  cidr_block           = "10.43.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "portfolio-infrastructure" }
}

resource "aws_subnet" "demo" {
  vpc_id                  = aws_vpc.demo.id
  cidr_block              = "10.43.1.0/24"
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = false
  tags                    = { Name = "portfolio-public" }
}

resource "aws_internet_gateway" "demo" {
  vpc_id = aws_vpc.demo.id
}

resource "aws_route_table" "demo" {
  vpc_id = aws_vpc.demo.id
}

resource "aws_route" "internet" {
  route_table_id         = aws_route_table.demo.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.demo.id
}

resource "aws_route_table_association" "demo" {
  subnet_id      = aws_subnet.demo.id
  route_table_id = aws_route_table.demo.id
}

resource "aws_security_group" "host" {
  name_prefix = "portfolio-host-"
  description = "No inbound access; HTTPS outbound for Systems Manager"
  vpc_id      = aws_vpc.demo.id
  ingress     = []
}

resource "aws_vpc_security_group_egress_rule" "https" {
  security_group_id = aws_security_group.host.id
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_iam_role" "host" {
  count       = var.enable_host ? 1 : 0
  name_prefix = "portfolio-host-"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  count      = var.enable_host ? 1 : 0
  role       = aws_iam_role.host[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "host" {
  count       = var.enable_host ? 1 : 0
  name_prefix = "portfolio-host-"
  role        = aws_iam_role.host[0].name
}

resource "aws_instance" "host" {
  count                       = var.enable_host ? 1 : 0
  ami                         = var.ami_id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.demo.id
  vpc_security_group_ids      = [aws_security_group.host.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.host[0].name

  metadata_options {
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }
  root_block_device {
    encrypted             = true
    volume_type           = "gp3"
    volume_size           = 8
    delete_on_termination = true
  }
  credit_specification {
    cpu_credits = "standard"
  }
  tags = { Name = "portfolio-infrastructure-demo" }
  depends_on = [
    aws_route.internet,
    aws_route_table_association.demo,
    aws_vpc_security_group_egress_rule.https,
    aws_iam_role_policy_attachment.ssm,
  ]
}
