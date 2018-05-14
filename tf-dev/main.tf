variable "name_prefix" {
  default = "dev001"
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

provider "aws" {
  region = "${var.aws_region}"
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
