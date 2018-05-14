# VPC
variable "vpc_cidr" {
  default = "172.22.0.0/16"
}

variable "public_subnet_cidr" {
  default = "172.22.1.0/24"
}

variable "private_subnet_cidr_1" {
  default = "172.22.2.0/24"
}

variable "private_subnet_cidr_2" {
  default = "172.22.3.0/24"
}

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
  availability_zone       = "${var.aws_region}a"

  tags {
    Name        = "${var.name_prefix}-public-subnet"
    Environment = "${var.tag_environment}"
    Owner       = "${var.tag_owner}"
  }
}

resource "aws_subnet" "private-1" {
  vpc_id            = "${aws_vpc.default.id}"
  cidr_block        = "${var.private_subnet_cidr_1}"
  availability_zone = "${var.aws_region}a"

  tags {
    Name        = "${var.name_prefix}-private-subnet-1"
    Environment = "${var.tag_environment}"
    Owner       = "${var.tag_owner}"
  }
}

resource "aws_subnet" "private-2" {
  vpc_id            = "${aws_vpc.default.id}"
  cidr_block        = "${var.private_subnet_cidr_2}"
  availability_zone = "${var.aws_region}b"

  tags {
    Name        = "${var.name_prefix}-private-subnet-2"
    Environment = "${var.tag_environment}"
    Owner       = "${var.tag_owner}"
  }
}



data aws_iam_policy_document iam_assume_role_policy {
  statement {
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "apigateway.amazonaws.com",
        "ec2.amazonaws.com",
        "lambda.amazonaws.com",
        "rds.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "api_role" {
  name = "api_role"
  assume_role_policy = "${data.aws_iam_policy_document.iam_assume_role_policy.json}"
}

data "aws_iam_policy_document" "lambda_iam_role_policy_document" {
  statement {
    sid = "1"

    actions = [
      "apigateway:*",
      "ec2:*",
      "cloudwatch:*",
      "lambda:*",
      "logs:*",
      "rds:*",
      "xray:*",
      "sns:*"
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "iam_policy" {
  name_prefix = "my-sweet-iam-policy-for-my-lambda"
  path = "/"
  policy = "${data.aws_iam_policy_document.lambda_iam_role_policy_document.json}"
}


resource "aws_iam_role_policy_attachment" "policy_attachment" {
  policy_arn = "${aws_iam_policy.iam_policy.arn}"
  role = "${aws_iam_role.api_role.name}"
}