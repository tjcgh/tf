resource "aws_s3_bucket" "host" {
  bucket = "${var.name_prefix}-app"
  acl    = "public-read"

  #policy = "${file("policy.json")}"

  website {
    index_document = "index.html"
    error_document = "index.html"

    routing_rules = <<EOF
[{
    "Condition": {
        "KeyPrefixEquals": "docs/"
    },
    "Redirect": {
        "ReplaceKeyPrefixWith": "documents/"
    }
}]
EOF
  }
  tags {
    Name        = "${var.name_prefix}-aws_s3_bucket"
    Environment = "${var.tag_environment}"
    Owner       = "${var.tag_owner}"
  }
}
