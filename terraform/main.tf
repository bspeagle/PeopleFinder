variable "access_key" {}
variable "secret_key" {}
variable "region" {}

variable "app" {
  type    = "string"
  default = "PeopleFinder"
}

variable "env" {
  type    = "string"
  default = "PROD"
}

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

/*resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"

  tags {
    Name = "PeopleFinder-VPC"
    App  = "${var.app}"
    Env  = "${var.env}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "PeopleFinder-IGW"
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
    Name = "PeopleFinder-SNG-1"
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
    Name = "PeopleFinder-SNG-2"
    App  = "${var.app}"
    Env  = "${var.env}"
  }
}

resource "aws_network_acl" "acl" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "PeopleFinder-ACL"
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
    Name = "PeopleFinder-VPC-ROUTES"
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

resource "aws_security_group" "ec2sg" {
  name        = "PeopleFinder-EC2-SG"
  description = "SG for EC2 instances"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "PeopleFinder-SG-EC2"
    App  = "${var.app}"
    Env  = "${var.env}"
  }
}

resource "aws_security_group" "lbsg" {
  name        = "PeopleFinder-LB-SG"
  description = "SG for LB"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "PeopleFinder-SG-LB"
    App  = "${var.app}"
    Env  = "${var.env}"
  }
}*/


/*data "template_file" "user_data-nginx" {
  template = "${file("../files/user_data-nginx.tpl")}"
}*/


/*resource "aws_launch_configuration" "lConfigWeb" {
  name            = "PeopleFinder-ASLC-WEB"
  image_id        = "ami-334e134c"
  instance_type   = "t2.micro"
  security_groups = ["${aws_security_group.ec2sg.id}"]

  //user_data       = "${data.template_file.user_data-nginx.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asgWeb" {
  name                      = "PeopleFinder-ASG-WEB"
  max_size                  = 2
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 1
  launch_configuration      = "${aws_launch_configuration.lConfigWeb.name}"

  vpc_zone_identifier = [
    "${aws_subnet.snELB1.id}",
    "${aws_subnet.snELB2.id}",
  ]

  lifecycle {
    create_before_destroy = true
  }

  depends_on = ["aws_nat_gateway.ngw"]
}

resource "aws_lb_target_group" "lb-tg-web" {
  name     = "PeopleFinder-TG-WEB"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.vpc.id}"

  tags {
    Name = "PeopleFinder-TG-WEB"
    App  = "${var.app}"
    Env  = "${var.env}"
  }
}

resource "aws_autoscaling_attachment" "asg-tg-attach" {
  autoscaling_group_name = "${aws_autoscaling_group.asgWeb.id}"
  alb_target_group_arn   = "${aws_lb_target_group.lb-tg-web.arn}"
}

resource "aws_lb" "lb-web" {
  name               = "PeopleFinder-LB-WEB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.lbsg.id}"]

  subnets = [
    "${aws_subnet.snELB1.id}",
    "${aws_subnet.snELB2.id}",
  ]

  tags {
    Name = "PeopleFinder-LB-WEB"
    App  = "${var.app}"
    Env  = "${var.env}"
  }
}

resource "aws_lb_listener" "forward" {
  load_balancer_arn = "${aws_lb.lb-web.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.lb-tg-web.arn}"
    type             = "forward"
  }
}*/

