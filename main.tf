terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.41.0"
    }
  }
  backend "s3" {
    bucket         = "my-unique-bucket-21aa2d99"
    key            = "state/terraform.tfstate"
    region         = "ap-northeast-1"
    encrypt        = true
    dynamodb_table = "my-components_tf_lockid"
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_s3_bucket" "example" {
  bucket = "my-unique-bucket-${random_id.bucket_id.hex}"
  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = "my-unique-bucket-${random_id.bucket_id.hex}"

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "example" {
  depends_on = [aws_s3_bucket_ownership_controls.example]

  bucket = "my-unique-bucket-${random_id.bucket_id.hex}"
  acl    = "private"
}

resource "random_id" "bucket_id" {
  byte_length = 4
}

resource "aws_s3_bucket_public_access_block" "app" {
  bucket                  = "my-unique-bucket-${random_id.bucket_id.hex}"
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

