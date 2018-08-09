variable "app" {}
variable "env" {}
variable "vpc_id" {}
variable "snELB1_id" {}
variable "snELB2_id" {}
variable "ec2sg_id" {}
variable "lbsg_id" {}
variable "ecsIAMrole_name" {}
variable "ecsIAMtaskrole_arn" {}
variable "ecsIAMsvcrole_arn" {}
variable "ecsIAMrole_profile_name" {}

resource "aws_lb_target_group" "lb-tg-web" {
  name     = "PeopleFinder-TG-WEB-${var.env}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  tags {
    Name = "PeopleFinder-TG-WEB-${var.env}"
    App  = "${var.app}"
    Env  = "${var.env}"
  }
}

resource "aws_lb" "lb-web" {
  name               = "PeopleFinder-LB-WEB-${var.env}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${var.lbsg_id}"]

  subnets = [
    "${var.snELB1_id}",
    "${var.snELB2_id}",
  ]

  tags {
    Name = "PeopleFinder-LB-WEB-${var.env}"
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
}

resource "aws_ecs_cluster" "cluster1" {
  name = "PeopleFinder-${var.env}"
}

resource "aws_instance" "ec2_A" {
  ami           = "ami-fbc1c684"
  instance_type = "t2.micro"
  subnet_id     = "${var.snELB1_id}"
  security_groups = ["${var.ec2sg_id}"]

  user_data = <<EOF
    #!/bin/bash
    echo ECS_CLUSTER=${aws_ecs_cluster.cluster1.name} >> /etc/ecs/ecs.config
  EOF

  iam_instance_profile = "${var.ecsIAMrole_profile_name}"
}

resource "aws_instance" "ec2_B" {
  ami           = "ami-fbc1c684"
  instance_type = "t2.micro"
  subnet_id     = "${var.snELB2_id}"
  security_groups = ["${var.ec2sg_id}"]

  user_data = <<EOF
    #!/bin/bash
    echo ECS_CLUSTER=${aws_ecs_cluster.cluster1.name} >> /etc/ecs/ecs.config
  EOF

  iam_instance_profile = "${var.ecsIAMrole_profile_name}"
}

resource "aws_ecs_task_definition" "pf_deploy_app" {
  family                = "pf_app_deploy-${var.env}"
  network_mode          = "host"
  task_role_arn         = "${var.ecsIAMtaskrole_arn}"
  container_definitions = "${file("../../files/service.json")}"
}

resource "aws_ecs_service" "pfAppDeploy_A" {
  name            = "PF-App-Deploy"
  cluster         = "${aws_ecs_cluster.cluster1.id}"
  task_definition = "${aws_ecs_task_definition.pf_deploy_app.arn}"
  desired_count   = 1
  iam_role        = "${var.ecsIAMsvcrole_arn}"

  load_balancer {
    target_group_arn = "${aws_lb_target_group.lb-tg-web.arn}"
    container_name   = "PeopleFinder"
    container_port   = 80
  }

  depends_on = ["aws_instance.ec2_A", "aws_instance.ec2_B", "aws_lb.lb-web"]
}

resource "aws_route53_record" "www" {
  zone_id = "Z2QO00XWGGR1VX"
  name    = "peoplefinder.teamspeagle.com"
  type    = "A"

  alias {
    name                   = "${aws_lb.lb-web.dns_name}"
    zone_id                = "${aws_lb.lb-web.zone_id}"
    evaluate_target_health = true
  }
}