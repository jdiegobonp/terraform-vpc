# vpc resource
resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(
    {
      "Name" = format("vpc-%s-%s", var.project, var.environment)
    },
    var.tags,
  )
}

# private subnets resource
resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.az[count.index]

  tags = merge(
    {
      "Name" = format(
        "%s-%s-%s-%s",
        var.private_subnets[count.index],
        var.project,
        var.az[count.index],
        var.environment,
      )
    },
    var.tags
  )
}

# public subnets resource
resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(concat(var.public_subnets, [""]), count.index)
  availability_zone = var.az[count.index]

  tags = merge(
    {
      "Name" = format(
        "%s-%s-%s-%s",
        var.public_subnets[count.index],
        var.project,
        var.az[count.index],
        var.environment,
      )
    },
    var.tags
  )
}

# Elastic IP resource
resource "aws_eip" "eip" {
  vpc = true
  tags = merge(
    {
      Name = "eip-${var.project}-${var.environment}"
    },
    var.tags
  )
}

# Internet Gateway resource
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(
    {
      Name = "igw-${var.project}-${var.environment}"
    },
    var.tags
  )
}

# Nat Gateway resource
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public.*.id[0]
  depends_on    = [aws_internet_gateway.igw]
  tags = merge(
    {
      Name = "nat-${var.project}-${var.environment}"
    },
    var.tags
  )
}

# Route table to private subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    {
      "Name" = "rtb-${var.project}-${var.environment}"
    },
    var.tags
  )
}

# Rule to private route table
resource "aws_route" "private" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

# Route table to public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    {
      "Name" = "rtb-${var.project}-${var.environment}"
    },
    var.tags,
  )
}

# Rule to public route table
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Association route table with private subnets
resource "aws_route_table_association" "private" {
  count = length(var.private_subnets)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private.id
}

# Association route table with public subnets
resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}