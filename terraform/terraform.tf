terraform {
  cloud {
    organization = "aws-ado-devops"
    workspaces {
      name = "explore"
    }
  }

  required_version = ">= 1.0.0, < 2.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }
  }
}
locals {
  tags = {
    Name       = "CamTFBucket"
    Purpose    = "VerifyS3Build"
    repo       = "explore"
    managed-by = "terraform"
  }
}

provider "aws" {
  region = "us-west-2"
  default_tags {
    tags = local.tags
  }
}