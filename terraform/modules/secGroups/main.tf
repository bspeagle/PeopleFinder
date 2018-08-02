variable "app" {}
variable "env" {}
variable "vpc_id" {}


resource "aws_security_group" "ec2sg" {
  name        = "PeopleFinder-EC2-SG"
  description = "SG for EC2 instances"
  vpc_id      = "${var.vpc_id}"

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
    Name = "PeopleFinder-SG-EC2-${var.env}"
    App  = "${var.app}"
    Env  = "${var.env}"
  }
}

resource "aws_security_group" "lbsg" {
  name        = "PeopleFinder-LB-SG"
  description = "SG for LB"
  vpc_id      = "${var.vpc_id}"

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
    Name = "PeopleFinder-SG-LB-${var.env}"
    App  = "${var.app}"
    Env  = "${var.env}"
  }
}

output "lbsg_id" {
  value = "${aws_security_group.lbsg.id}"
}

output "ec2sg_id" {
  value = "${aws_security_group.ec2sg.id}"
}
