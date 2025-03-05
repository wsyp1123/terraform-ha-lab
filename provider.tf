terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.89.0"
    }
  }
  backend "s3" {
    bucket         = "terraform-state-bucket-wsy"
    dynamodb_table = "TerraformLock"
    encrypt        = true
    key            = "state/terraform-class/terraform.tfstate"
    region         = "ap-southeast-1"
  }
}

provider "aws" {
  region = "ap-southeast-1"
}