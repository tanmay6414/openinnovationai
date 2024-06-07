variable "cluster_name" {
    type = string
    default = "TestCluster"  
}
variable "kubernetes_version" {
  type = string
  default = "1.28"
}
variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint"
  type        = list(string)
  default = [
    "0.0.0.0/0",
  ]
}

variable "aws_default_tags" {
  type = map(string)
  default = {
    "Purpose" = "Demo"
    "Creator" = "tanmay"
  }
}
variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

data "aws_eks_addon_version" "coredns" {
  addon_name         = "coredns"
  kubernetes_version = var.kubernetes_version
}

data "aws_eks_addon_version" "vpc_cni" {
  addon_name         = "vpc-cni"
  kubernetes_version = var.kubernetes_version
}

data "aws_eks_addon_version" "kube_proxy" {
  addon_name         = "kube-proxy"
  kubernetes_version = var.kubernetes_version
}

data "terraform_remote_state" "network" {
  backend = "local"
  config = {
    path = "../network/terraform.tfstate"
  }
}
