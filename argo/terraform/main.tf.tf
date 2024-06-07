
data "aws_eks_cluster" "cluster" {
  name = "TestCluster"
}

resource "argocd_cluster" "eks" {
  server = data.aws_eks_cluster.cluster.endpoint
  name   = "TestCluster"
  config {
    aws_auth_config {
      cluster_name = "TestCluster"
    }
    tls_client_config {
      ca_data = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    }
  }
}
