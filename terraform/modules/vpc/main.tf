variable "app" {}
variable "env" {}


resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"

  tags {
    Name = "PeopleFinder-VPC-${var.env}"
    App  = "${var.app}"
    Env  = "${var.env}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "PeopleFinder-IGW-${var.env}"
    App  = "${var.app}"
    Env  = "${var.env}"
  }
}

resource "aws_subnet" "snELB1" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags {
    Name = "PeopleFinder-SNG-1-${var.env}"
    App  = "${var.app}"
    Env  = "${var.env}"
  }
}

resource "aws_subnet" "snELB2" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags {
    Name = "PeopleFinder-SNG-2-${var.env}"
    App  = "${var.app}"
    Env  = "${var.env}"
  }
}

resource "aws_network_acl" "acl" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "PeopleFinder-ACL-${var.env}"
    App  = "${var.app}"
    Env  = "${var.env}"
  }
}

resource "aws_route_table" "routeTable" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags {
    Name = "PeopleFinder-VPC-ROUTES-${var.env}"
    App  = "${var.app}"
    Env  = "${var.env}"
  }
}

resource "aws_route_table_association" "rta-A" {
  subnet_id      = "${aws_subnet.snELB1.id}"
  route_table_id = "${aws_route_table.routeTable.id}"
}

resource "aws_route_table_association" "rta-B" {
  subnet_id      = "${aws_subnet.snELB2.id}"
  route_table_id = "${aws_route_table.routeTable.id}"
}

resource "aws_eip" "eIP-NAT" {
  vpc = true
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = "${aws_eip.eIP-NAT.id}"
  subnet_id     = "${aws_subnet.snELB1.id}"

  depends_on = ["aws_internet_gateway.igw"]
}

output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "snELB1_id" {
  value = "${aws_subnet.snELB1.id}"
}

output "snELB2_id" {
  value = "${aws_subnet.snELB2.id}"
}