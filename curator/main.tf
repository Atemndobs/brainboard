resource "aws_vpc" "vpc" {
  tags       = merge(var.tags, {})
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "snet" {
  vpc_id            = aws_vpc.vpc.id
  tags              = merge(var.tags, {})
  cidr_block        = "10.0.1.0/24"
  availability_zone = var.az1
}

resource "aws_subnet" "snet2" {
  vpc_id            = aws_vpc.vpc.id
  tags              = merge(var.tags, {})
  cidr_block        = "10.0.2.0/24"
  availability_zone = var.az2
}

resource "aws_internet_gateway" "internet_gw" {
  vpc_id = aws_vpc.vpc.id
  tags   = merge(var.tags, {})
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id
  tags   = merge(var.tags, {})

  route {
    gateway_id = aws_internet_gateway.internet_gw.id
    cidr_block = "0.0.0.0/0"
  }
}

resource "aws_route_table_association" "rt_association" {
  subnet_id      = aws_subnet.snet.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "rt_association2" {
  subnet_id      = aws_subnet.snet2.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_eks_cluster" "eks_cluster" {
  tags     = merge(var.tags, {})
  role_arn = aws_iam_role.iam_role.arn
  name     = "Onboarding"

  vpc_config {
    subnet_ids = [
      aws_subnet.snet.id,
      aws_subnet.snet2.id,
    ]
  }
}

resource "aws_iam_role" "iam_role" {
  tags = merge(var.tags, {})
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "sts:AssumeRole",
        Principal = {
          Service = "eks.amazonaws.com"
        }

      },
    ]
  })
}

