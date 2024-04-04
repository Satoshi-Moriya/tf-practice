terraform {
  required_version = "~> 1.7.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.35.0"
    }
  }

  backend "s3" {
    bucket = "moriya-tfstate"
    key    = "terraform.tfstate"
    region = "ap-northeast-1"
  }
}

provider "aws" {
  region = "ap-northeast-1"

  default_tags {
    tags = {
      "Project" = "moriya"
      "Provisioning" = "Terraform"
    }
  }
}


resource "aws_vpc" "default" {
  cidr_block       = "10.10.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "demo-vpc"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "demo-igw"
  }
}

resource "aws_eip" "nat_1a" {
  domain = "vpc"

  tags = {
    Name = "demo-nat-1a"
  }
}

resource "aws_nat_gateway" "nat_1a" {
  allocation_id = aws_eip.nat_1a.id
  subnet_id     = aws_subnet.public_1a.id

  tags = {
    Name = "demo-nat-1a"
  }
}

resource "aws_eip" "nat_1c" {
  domain = "vpc"

  tags = {
    Name = "demo-nat-1c"
  }
}

resource "aws_nat_gateway" "nat_1c" {
  allocation_id = aws_eip.nat_1c.id
  subnet_id     = aws_subnet.public_1c.id

  tags = {
    Name = "demo-nat-1c"
  }
}

resource "aws_subnet" "public_1a" {
  vpc_id            = aws_vpc.default.id
  cidr_block        = "10.10.1.0/24"
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "demo-public-subnet-1a"
  }
}

resource "aws_subnet" "public_1c" {
  vpc_id            = aws_vpc.default.id
  cidr_block        = "10.10.2.0/24"
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "demo-public-subnet-1c"
  }
}

resource "aws_subnet" "private_1a" {
  vpc_id            = aws_vpc.default.id
  cidr_block        = "10.10.3.0/24"
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "demo-private-subnet-1a"
  }
}

resource "aws_subnet" "private_1c" {
  vpc_id            = aws_vpc.default.id
  cidr_block        = "10.10.4.0/24"
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "demo-private-subnet-1c"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "demo-public-route-table"
  }
}

resource "aws_route" "public" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id = aws_route_table.public.id
  gateway_id = aws_internet_gateway.default.id
}

resource "aws_route_table_association" "public_1a" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_1c" {
  subnet_id      = aws_subnet.public_1c.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private_1a" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "demo-private-route-table-1a"
  }
}

resource "aws_route_table" "private_1c" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "demo-private-route-table-1c"
  }
}

resource "aws_route" "private_1a" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id = aws_route_table.private_1a.id
  nat_gateway_id = aws_nat_gateway.nat_1a.id
}

resource "aws_route" "private_1c" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id = aws_route_table.private_1c.id
  nat_gateway_id = aws_nat_gateway.nat_1c.id
}

resource "aws_route_table_association" "private_1a" {
  subnet_id      = aws_subnet.private_1a.id
  route_table_id = aws_route_table.private_1a.id
}

resource "aws_route_table_association" "private_1c" {
  subnet_id      = aws_subnet.private_1c.id
  route_table_id = aws_route_table.private_1c.id
}