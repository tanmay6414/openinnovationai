resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = "true"
  tags = merge(
    { Name = "Testing_VPC" },
  var.aws_default_tags)
}

resource "aws_subnet" "utility_a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.utility_a_cidr
  availability_zone = var.aws_az_a

  tags = merge({ Name = "aza_public_subnet", "kubernetes.io/role/elb" = "" })
}
resource "aws_subnet" "utility_b" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.utility_b_cidr
  availability_zone = var.aws_az_b

  tags = merge({ Name = "aza_public_subnet", "kubernetes.io/role/elb" = "" })
}

resource "aws_subnet" "app_a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.app_a_cidr
  availability_zone = var.aws_az_a

  tags = merge({ Name = "az1_private_subnet", "kubernetes.io/role/internal-elb" = "" })
}
resource "aws_subnet" "app_b" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.app_b_cidr
  availability_zone = var.aws_az_b

  tags = merge({ Name = "az1_private_subnet", "kubernetes.io/role/internal-elb" = "" })
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags   = merge({ Name = "Testing_igw" })
}

resource "aws_eip" "nat_a" {
  domain = "vpc"

  tags = merge({ Name = "aws_az_a_eip" })
}
resource "aws_eip" "nat_b" {
  domain = "vpc"

  tags = merge({ Name = "aws_az_b_eip" })
}



resource "aws_nat_gateway" "ngw_a" {
  allocation_id = aws_eip.nat_a.id
  subnet_id     = aws_subnet.utility_a.id

  tags = merge({ Name = "az_a_nat" })
}

resource "aws_nat_gateway" "ngw_b" {
  allocation_id = aws_eip.nat_b.id
  subnet_id     = aws_subnet.utility_b.id

  tags = merge({ Name = "az_b_nat" })
}


# # public route table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  tags = merge({ Name = "public_rt" })
}

resource "aws_route" "public_igw_rt" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "utility_a" {
  subnet_id      = aws_subnet.utility_a.id
  route_table_id = aws_route_table.public_rt.id
}


# #private route
resource "aws_route_table" "private_a_rt" {
  vpc_id = aws_vpc.vpc.id

  tags = merge({ Name = "private_az_a_route_table" })

}

resource "aws_route" "private_a_natgw_a_rt" {
  route_table_id         = aws_route_table.private_a_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ngw_a.id
}

resource "aws_route_table_association" "app_a" {
  subnet_id      = aws_subnet.app_a.id
  route_table_id = aws_route_table.private_a_rt.id
}


resource "aws_route_table" "private_b_rt" {
  vpc_id = aws_vpc.vpc.id

  tags = merge({ Name = "private_az_b_route_table" })

}

resource "aws_route" "private_a_natgw_b_rt" {
  route_table_id         = aws_route_table.private_b_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ngw_b.id
}

resource "aws_route_table_association" "app_b" {
  subnet_id      = aws_subnet.app_b.id
  route_table_id = aws_route_table.private_b_rt.id
}
