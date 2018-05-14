variable "name_prefix" {
  default = "loancures-dev-001"
}

variable "tag_environment" {
  default = "Development"
}

variable "tag_owner" {
  default = "TJC"
}

variable "aws_region" {
  default = "us-west-1"
}

variable "vpc_cidr" {
  default = "172.43.0.0/16"
}

variable "public_subnet_cidr" {
  default = "172.43.1.0/24"
}

variable "private_subnet_cidr" {
  default = "172.43.2.0/24"
}

variable "private_subnet_cidr_lambda" {
  default = "172.43.3.0/24"
}

variable "private_subnet_cidr_datasync" {
  default = "172.43.4.0/24"
}

variable "database_port" {
  default = "5432"
}

variable "database_username" {
  default = "admin_user"
}

variable "database_password" {}

variable "aws_ami" {
  description = "The specific AMI to use. AMIs are region specific so be sure  to pick the right one! Default is UBuntu 16.04"

  #  default     = "ami-916f59f4"
  default = "ami-e1131781"
}

variable "logstash_instance_type" {
  description = "The instance type to launch logstash on. Note - some instance types only work on some regions"
  default     = "t2.micro"
}

provider "aws" {
  region = "${var.aws_region}"
}

# VPC
resource "aws_vpc" "default" {
  cidr_block = "${var.vpc_cidr}"

  tags {
    Name        = "${var.name_prefix}-vpc"
    Environment = "${var.tag_environment}"
    Owner       = "${var.tag_owner}"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "${var.public_subnet_cidr}"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}b"

  tags {
    Name        = "${var.name_prefix}-public-subnet"
    Environment = "${var.tag_environment}"
    Owner       = "${var.tag_owner}"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = "${aws_vpc.default.id}"
  cidr_block        = "${var.private_subnet_cidr}"
  availability_zone = "${var.aws_region}c"

  tags {
    Name        = "${var.name_prefix}-private-subnet"
    Environment = "${var.tag_environment}"
    Owner       = "${var.tag_owner}"
  }
}

resource "aws_subnet" "private_subnet_cidr_datasync" {
  vpc_id            = "${aws_vpc.default.id}"
  cidr_block        = "${var.private_subnet_cidr_datasync}"
  availability_zone = "${var.aws_region}c"

  tags {
    Name        = "${var.name_prefix}-private_subnet_cidr_datasync"
    Environment = "${var.tag_environment}"
    Owner       = "${var.tag_owner}"
  }
}

resource "aws_db_subnet_group" "default" {
  name       = "main_subnet_group"
  subnet_ids = ["${aws_subnet.private.id}", "${aws_subnet.public.id}"]

  tags {
    Name        = "${var.name_prefix}-aws_db_subnet_group"
    Environment = "${var.tag_environment}"
    Owner       = "${var.tag_owner}"
  }
}

output "id" {
  value = "${aws_db_instance.postgresql.id}"
}

output "database_security_group_id" {
  value = "${aws_security_group.database.id}"
}

output "hosted_zone_id" {
  value = "${aws_db_instance.postgresql.hosted_zone_id}"
}

output "hostname" {
  value = "${aws_db_instance.postgresql.address}"
}

output "port" {
  value = "${aws_db_instance.postgresql.port}"
}

output "endpoint" {
  value = "${aws_db_instance.postgresql.endpoint}"
}
