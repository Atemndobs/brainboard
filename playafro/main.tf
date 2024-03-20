resource "aws_vpc" "vpc" {
  tags       = merge(var.tags, { Name = "vpc" })
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public_snet_1a" {
  vpc_id                  = aws_vpc.vpc.id
  tags                    = merge(var.tags, { Name = "Public Subnet" })
  map_public_ip_on_launch = true
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
}

resource "aws_subnet" "public_snet_1b" {
  vpc_id            = aws_vpc.vpc.id
  tags              = merge(var.tags, { Name = "Public Subnet" })
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id
  tags   = merge(var.tags, { Name = "Public Route Table" })

  route {
    gateway_id = aws_internet_gateway.internet_gw.id
    cidr_block = "0.0.0.0/0"
  }
}

resource "aws_route_table_association" "rt_association_1a" {
  subnet_id      = aws_subnet.public_snet_1a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "rt_association_1b" {
  subnet_id      = aws_subnet.public_snet_1b.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_internet_gateway" "internet_gw" {
  vpc_id = aws_vpc.vpc.id
  tags   = merge(var.tags, {})
}

resource "aws_subnet" "private_snet_1a" {
  vpc_id                  = aws_vpc.vpc.id
  tags                    = merge(var.tags, { Name = "Private Subnet us-east-1a" })
  map_public_ip_on_launch = false
  cidr_block              = "10.0.101.0/24"
  availability_zone       = "us-east-1a"
}

resource "aws_subnet" "private_snet_1b" {
  vpc_id                  = aws_vpc.vpc.id
  tags                    = merge(var.tags, { Name = "Private Subnet us-east-1b" })
  map_public_ip_on_launch = false
  cidr_block              = "10.0.102.0/24"
  availability_zone       = "us-east-1b"
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc.id
  tags   = merge(var.tags, { Name = "Private Route Table" })
}

resource "aws_route_table_association" "private_rt_association_1a" {
  subnet_id      = aws_subnet.private_snet_1a.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_rt_association_1b" {
  subnet_id      = aws_subnet.private_snet_1b.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_security_group" "ec2_sg" {
  vpc_id      = aws_vpc.vpc.id
  tags        = merge(var.tags, { Name = "Public Instance Security Group" })
  name        = "public-instance-sg"
  description = "Security group for public instance in public subnet"

  egress {
    to_port   = 0
    protocol  = "-1"
    from_port = 0
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  ingress {
    to_port     = 80
    protocol    = "tcp"
    from_port   = 80
    description = "Rule allowing HTTP ingress"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
  ingress {
    to_port     = 22
    protocol    = "tcp"
    from_port   = 22
    description = "Rule allowing SSH ingress"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}

resource "aws_db_instance" "private_db_instance_1a" {
  username             = "playafro"
  tags                 = merge(var.tags, { Name = "Private DB Instance" })
  storage_type         = "gp2"
  password             = "playafro"
  parameter_group_name = "default.mysql8.0"
  instance_class       = "db.t3.micro"
  engine_version       = "8.0"
  engine               = "mysql"
  db_subnet_group_name = aws_db_subnet_group.db_snet_group_1a.name
  db_name              = "playafro"
  availability_zone    = "us-east-1a"
  allocated_storage    = 1

  vpc_security_group_ids = [
    aws_security_group.db_sg.id,
  ]
}

resource "aws_security_group" "db_sg" {
  vpc_id      = aws_vpc.vpc.id
  tags        = merge(var.tags, { Name = "Private DB Security Group" })
  name        = "private-db-sg"
  description = "Security group for RDS DB instance in private subnet"

  egress {
    to_port   = 0
    protocol  = "-1"
    from_port = 0
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  ingress {
    to_port   = 3306
    self      = true
    protocol  = "tcp"
    from_port = 3306
  }
}

resource "aws_db_subnet_group" "db_snet_group_1a" {
  tags        = merge(var.tags, { Name = "Private DB Subnet Group 1a" })
  name        = "private-db-subnet-group"
  description = "AWS RDS database in the us-east-1a private subnet"

  subnet_ids = [
    aws_subnet.private_snet_1a.id,
  ]
}

resource "aws_db_subnet_group" "db_snet_group_1b" {
  tags        = merge(var.tags, { Name = "Private DB Subnet Group 1b" })
  name        = "private-db-subnet-group-1b"
  description = "AWS RDS database in the us-east-1b private subnet"

  subnet_ids = [
    aws_subnet.private_snet_1b.id,
  ]
}

resource "aws_db_instance" "private_db_instance_1b" {
  username             = "playafro"
  tags                 = merge(var.tags, { Name = "Private DB Instance" })
  storage_type         = "gp2"
  password             = "playafro"
  parameter_group_name = "default.mysql8.0"
  instance_class       = "db.t3.micro"
  engine_version       = "8.0"
  engine               = "mysql"
  db_subnet_group_name = aws_db_subnet_group.db_snet_group_1b.name
  db_name              = "playafro"
  availability_zone    = "us-east-1b"
  allocated_storage    = 1

  vpc_security_group_ids = [
    aws_security_group.db_sg.id,
  ]
}

resource "aws_instance" "web_ec2_t3_1a" {
  tags                        = merge(var.tags, { Name = "Web Tier EC2 T3 1a" })
  subnet_id                   = aws_subnet.public_snet_1a.id
  instance_type               = "t3.micro"
  availability_zone           = "us-east-1a"
  associate_public_ip_address = true
  ami                         = "ami-0d7682ee79dc266a9"

  vpc_security_group_ids = [
    aws_security_group.ec2_sg.id,
  ]
}

resource "aws_instance" "web_ec2_t3_1b" {
  tags                        = merge(var.tags, { Name = "Web Tier EC2 T3 1b" })
  subnet_id                   = aws_subnet.public_snet_1b.id
  instance_type               = "t3.micro"
  availability_zone           = "us-east-1b"
  associate_public_ip_address = true
  ami                         = "ami-0d7682ee79dc266a9"

  vpc_security_group_ids = [
    aws_security_group.ec2_sg.id,
  ]
}

resource "aws_instance" "internal_apps_ec2_1a" {
  tags                        = merge(var.tags, { Name = "App Tier EC2 T3 1a" })
  subnet_id                   = aws_subnet.private_snet_1a.id
  instance_type               = "t3.micro"
  availability_zone           = "us-east-1a"
  associate_public_ip_address = false
  ami                         = "ami-0d7682ee79dc266a9"

  vpc_security_group_ids = [
    aws_security_group.app_sg.id,
  ]
}

resource "aws_instance" "internal_apps_ec2_1b" {
  tags                        = merge(var.tags, { Name = "App Tier EC2 T3 1b" })
  subnet_id                   = aws_subnet.private_snet_1b.id
  instance_type               = "t3.micro"
  availability_zone           = "us-east-1b"
  associate_public_ip_address = false
  ami                         = "ami-0d7682ee79dc266a9"

  vpc_security_group_ids = [
    aws_security_group.app_sg.id,
  ]
}

resource "aws_security_group" "app_sg" {
  vpc_id      = aws_vpc.vpc.id
  tags        = merge(var.tags, { Name = "Application Tier Security Group" })
  name        = "app-sg"
  description = "Security group for application tier EC2 instances in private subnet"

  egress {
    to_port   = 0
    protocol  = "-1"
    from_port = 0
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  ingress {
    to_port     = 8080
    protocol    = "tcp"
    from_port   = 8080
    description = "Rule allowing HTTP ingress"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
    security_groups = [
      aws_security_group.ec2_sg.id,
    ]
  }
  ingress {
    to_port     = 22
    protocol    = "tcp"
    from_port   = 22
    description = "Rule allowing SSH ingress"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}

