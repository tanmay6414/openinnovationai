
terraform {
  required_providers {
    argocd = {
      source  = "mediwareinc/argocd"
      version = "2.2.6"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.23.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "5.26.0"
    }
  }
}

# those credential must able to access eks admin role
provider "aws" {
  region = "ap-south-1"
}

provider "argocd" {
  server_addr = "argocd.openinnovationai.com"
  username    = "admin"
  password    = ""
  grpc_web    = true
  insecure    = true
}

