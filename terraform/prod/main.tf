variable "access_key" {}
variable "secret_key" {}
variable "region" {}

variable "app" {
  type    = "string"
  default = "PeopleFinder"
}

variable "env" {
  type    = "string"
  default = "PROD-B"
}

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

module "vpc" {
  source = "../modules/vpc"
  app = "${var.app}"
  env = "${var.env}"
}

module "secGroups" {
  source = "../modules/secGroups"
  app = "${var.app}"
  env = "${var.env}"
  vpc_id = "${module.vpc.vpc_id}"
}

module "iAM" {
  source = "../modules/iAM"
  env = "${var.env}"
}

module "ecs" {
  source = "../modules/ecs"
  app = "${var.app}"
  env = "${var.env}"
  vpc_id = "${module.vpc.vpc_id}"
  snELB1_id = "${module.vpc.snELB1_id}"
  snELB2_id = "${module.vpc.snELB2_id}"
  ec2sg_id = "${module.secGroups.ec2sg_id}"
  lbsg_id = "${module.secGroups.lbsg_id}"
  ecsIAMrole_name = "${module.iAM.ecsIAMrole_name}"
  ecsIAMtaskrole_arn = "${module.iAM.ecsIAMtaskrole_arn}"
  ecsIAMsvcrole_arn = "${module.iAM.ecsIAMsvcrole_arn}"
  ecsIAMrole_profile_name = "${module.iAM.ecsIAMrole_profile_name}"
}