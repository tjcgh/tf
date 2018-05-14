# Package
variable "lambda-package" {
  default = "Archive.zip"
}

variable "lambda-source" {
  default = "db-utils"
}

variable "lambda-target" {
  default = "../loancures"
}

#resource "null_resource" "lambda-deployment" {
#  provisioner "local-exec" {
#    working_dir = "${var.lambda-source}"
#    command     = "( chalice package . || true )"

    #    command     = "( chalice package . || true && cp ${var.lambda-source}/${var.lambda-package} ${var.lambda-target}/${var.lambda-package})"
#  }
#}

# Deployment
variable "function_name" {
  default = "dev001-handler"
}

variable "handler" {
  default = "app.handler"
}

variable "runtime" {
  default = "python3.6"
}

resource "aws_iam_role" "lambda_exec_role" {
  #depends_on  = ["null_resource.lambda-deployment"]
  name        = "${var.name_prefix}-lambda_execution-role"
  path        = "/"
  description = "Auto-created by deployment of ${var.name_prefix}, allows Lambda Function to call AWS services."

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "lambda_function" {
  #depends_on    = ["null_resource.lambda-deployment"]
  role          = "${aws_iam_role.api_role.arn}"
  handler       = "${var.handler}"
  runtime       = "${var.runtime}"
  filename      = "${var.lambda-source}/${var.lambda-package}"
  function_name = "${var.function_name}"
  vpc_config{
      subnet_ids = ["${aws_subnet.private-1.id}", "${aws_subnet.private-2.id}"]
      security_group_ids = ["${aws_security_group.database.id}"]
  }
 
  #source_code_hash = "${base64sha256(file("${var.lambda-source}/${var.lambda-package}"))}"

  tags {
    Name        = "${var.name_prefix}-lambda-function"
    Environment = "${var.tag_environment}"
    Owner       = "${var.tag_owner}"
  }
}
