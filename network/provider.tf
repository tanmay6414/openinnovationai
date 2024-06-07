# terraform {
#   backend "s3" {
#     bucket                  = "open-innovation-ai"
#     key                     = "network.tfstate"
#     region                  = "us-east-1"
#     encrypt                 = true
#   }
# }

provider "aws" {
  region = var.aws_region
}