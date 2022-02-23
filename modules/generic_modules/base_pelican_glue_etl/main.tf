locals {
  max_retries = {
    dev = 1
    prod = 5
  }
  number_of_workers = {
    dev = 4
    prod = 10
  }
  time_out = {
    dev = 60
    prod = 120
  }
}

resource "aws_iam_role" "this" {
  name               = "${var.etl_name}_role"
  assume_role_policy = data.aws_iam_policy_document.role_trusted_entities.json
  inline_policy {
    name   = "${var.etl_name}_policy"
    policy = data.aws_iam_policy_document.inline_policy.json
  }
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "${var.etl_name}_log_group"
  retention_in_days = 5
}

resource "aws_glue_job" "this" {
  name     = var.etl_name
  role_arn = aws_iam_role.this.arn
  command {
    script_location = "s3://${var.scripts_bucket_name}/${var.environment}/${var.script_file_name}"
    python_version = 3
  }
  default_arguments = {
    "--continuous-log-logGroup"          = aws_cloudwatch_log_group.this.name
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-continuous-log-filter"     = "true"
    "--job-bookmark-option": "job-bookmark-enable"
  }
  glue_version = 3
  max_retries = lookup(local.max_retries, var.environment)
  worker_type = "Standard"
  number_of_workers = lookup(local.number_of_workers, var.environment)
  timeout = lookup(local.time_out, var.environment)
}

data "aws_iam_policy_document" "role_trusted_entities" {
  statement {
    principals {
      type = "Service"
      identifiers = ["glue.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "inline_policy" {
  statement {
    actions = [
      "s3:ListBucket",
    ]
    resources = [
      "arn:aws:s3:::*"
    ]
  }
}