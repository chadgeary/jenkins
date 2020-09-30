# vpc and gateway
resource "aws_vpc" "jenkins-vpc" {
  cidr_block              = var.vpc_cidr
  enable_dns_support      = "true"
  enable_dns_hostnames    = "true"
  tags                    = {
    Name                  = "jenkins-vpc"
  }
}

# internet gateway 
resource "aws_internet_gateway" "jenkins-gw" {
  vpc_id                  = aws_vpc.jenkins-vpc.id
  tags                    = {
    Name                  = "jenkins-gw"
  }
}

# public route table
resource "aws_route_table" "jenkins-pubrt" {
  vpc_id                  = aws_vpc.jenkins-vpc.id
  route {
    cidr_block              = "0.0.0.0/0"
    gateway_id              = aws_internet_gateway.jenkins-gw.id
  }
  tags                    = {
    Name                  = "jenkins-pubrt"
  }
}

# public subnets
resource "aws_subnet" "jenkins-pubnet1" {
  vpc_id                  = aws_vpc.jenkins-vpc.id
  availability_zone       = data.aws_availability_zones.jenkins-azs.names[0]
  cidr_block              = var.pubnet1_cidr
  tags                    = {
    Name                  = "jenkins-pubnet1"
  }
  depends_on              = [aws_internet_gateway.jenkins-gw]
}

# public route table associations
resource "aws_route_table_association" "rt-assoc-pubnet1" {
  subnet_id               = aws_subnet.jenkins-pubnet1.id
  route_table_id          = aws_route_table.jenkins-pubrt.id
}
