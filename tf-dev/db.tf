# Database

variable "database_port" {
  default = "5432"
}

variable "database_username" {
  default = "admin_user"
}
variable "database_password" {
  default = "!Race2Win!"
}

resource "aws_security_group" "database" {
  name   = "${var.aws_region}-db-security-group"
  vpc_id = "${aws_vpc.default.id}"

  ingress {
    from_port   = "${var.database_port}"
    to_port     = "${var.database_port}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "${var.name_prefix}-db-security-group"
    Environment = "${var.tag_environment}"
    Owner       = "${var.tag_owner}"
  }
}

resource "aws_db_subnet_group" "default" {
  name       = "main_subnet_group_db"
  subnet_ids = ["${aws_subnet.private-1.id}", "${aws_subnet.private-2.id}"]

  tags {
    Name        = "${var.name_prefix}-aws_db_subnet_group"
    Environment = "${var.tag_environment}"
    Owner       = "${var.tag_owner}"
  }
}

resource "aws_db_instance" "postgresql" {
  allocated_storage      = "20"
  storage_type           = "gp2"
  engine                 = "postgres"
  engine_version         = "9.6.6"
  instance_class         = "db.t2.micro"
  name                   = "dev001"
  identifier             = "${var.name_prefix}"
  password               = "${var.database_password}"
  username               = "${var.database_username}"
  db_subnet_group_name   = "${aws_db_subnet_group.default.id}"
  vpc_security_group_ids = ["${aws_security_group.database.id}"]
  port                   = "${var.database_port}"
  skip_final_snapshot    = true
  publicly_accessible    = false

  tags {
    Name        = "${var.name_prefix}-database"
    Environment = "${var.tag_environment}"
    Owner       = "${var.tag_owner}"
  }
}