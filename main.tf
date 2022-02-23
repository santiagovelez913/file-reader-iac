terraform {
  required_version = ">= 1.1.6 , < 2.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0.0"
    }
  }
  backend "s3" {
    ## the backend definition is empty here because is passed trough command line and defined in environments/${env}/backend-config.hcl
  }
}

provider "aws" {
  region = var.aws_region ## this comes from environments/${env}/main-vars.tfvars
}

locals {
  etlScriptsBucketName = "glue-etl-scripts-bucket"
}

module "etl1" {
  source = "./modules/generic_modules/base_pelican_glue_etl"
  etl_name = "etl1"
  environment = var.environment
  scripts_bucket_name = local.etlScriptsBucketName
  script_file_name = "test_etl_1.py"
}

module "etl2" {
  source = "./modules/generic_modules/base_pelican_glue_etl"
  etl_name = "etl2"
  environment = var.environment
  scripts_bucket_name = local.etlScriptsBucketName
  script_file_name = "test_etl_2.py"
}

module "etl3" {
  source = "./modules/adhoc_modules/adhoc_pelican_glue_etl3"
  etl_name = "etl3"
  environment = var.environment
  scripts_bucket_name = local.etlScriptsBucketName
  script_file_name = "test_etl_3.py"
}

module "s3EtlScriptsBucket"{
  source = "./modules/generic_modules/private-s3-bucket"
  bucket_name = local.etlScriptsBucketName
  allowed_roles_arns = toset([module.etl1.etl_arn])
  environment = var.environment
}
