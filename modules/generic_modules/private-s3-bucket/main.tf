locals {
  standard_tags = {
    environment = var.environment
  }
}

resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  tags = local.standard_tags
}

resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.allow_access.json
}

data "aws_iam_policy_document" "allow_access" {
  statement {
    principals {
      type        = "AWS"
      identifiers = var.allowed_roles_arns
    }
    actions = [
      "s3:GetObject",
      "s3:ListObjects",
      "s3:ListBucket",
    ]
    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*",
    ]
  }
}