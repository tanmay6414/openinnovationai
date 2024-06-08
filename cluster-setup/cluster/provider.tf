terraform {
  backend "s3" {
    bucket                  = "terraform-test-eks"
    key                     = "cluster/cluster.tfstate"
    region                  = "ap-south-1"
    encrypt                 = true
  }
}

provider "aws" {
  region = var.aws_region
}