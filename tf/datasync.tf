resource "aws_elasticsearch_domain" "es" {
  domain_name           = "general"
  elasticsearch_version = "6.2"

  cluster_config {
    instance_type = "t2.micro.elasticsearch"
  }

  advanced_options {
    "rest.action.multi.allow_explicit_index" = "true"
  }

  access_policies = <<CONFIG
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "es:*",
            "Principal": "*",
            "Effect": "Allow",
            "Condition": {
                "IpAddress": {"aws:SourceIp": ["66.193.100.22/32"]}
            }
        }
    ]
}
CONFIG

  snapshot_options {
    automated_snapshot_start_hour = 23
  }

  tags {
    Name        = "${var.name_prefix}-aws_elasticsearch_domain"
    Environment = "${var.tag_environment}"
    Owner       = "${var.tag_owner}"
  }
}

resource "aws_security_group" "logstash" {
  name        = "${var.name_prefix}-logstash-sg"
  description = "Used in the terraform logstash deploy"
  vpc_id      = "${aws_vpc.default.id}"

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "${var.name_prefix}-logstash-aws_security_group"
    Environment = "${var.tag_environment}"
    Owner       = "${var.tag_owner}"
  }
}

resource "aws_instance" "logstash" {
  depends_on    = ["aws_elasticsearch_domain.es"]
  instance_type = "${var.logstash_instance_type}"

  tags {
    Name        = "${var.name_prefix}-logstash"
    Environment = "${var.tag_environment}"
    Owner       = "${var.tag_owner}"
  }

  # Lookup the correct AMI
  ami = "${var.aws_ami}"

  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = ["${aws_security_group.logstash.id}"]

  # We're going to launch into the a private subnet for security
  subnet_id = "${aws_subnet.private_subnet_cidr_datasync.id}"

  tags {
    Name        = "${var.name_prefix}-logstash-aws_instance"
    Environment = "${var.tag_environment}"
    Owner       = "${var.tag_owner}"
  }
}
