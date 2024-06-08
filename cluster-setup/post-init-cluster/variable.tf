

variable "cluster_name" {
    default = "TestCluster"
  
}
data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}
variable "aws_kms_key" {
  default = ""
}