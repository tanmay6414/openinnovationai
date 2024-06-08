#Intall cluster autoscaler for high availability
resource "helm_release" "cluster-autoscaler" {
  name       = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  version    = "9.10.9"
  namespace  = "kube-system"
  set {
    name  = "autoDiscovery.clusterName"
    value = var.cluster_name
  }
}

#install storageclass for pvc
resource "kubernetes_storage_class" "ebs" {
  metadata {
    labels = {
        k8s-addon = "storage-aws.addons.k8s.io"
    }
    name   = "ebs"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = true
    }
  }
  storage_provisioner    = "kubernetes.io/aws-ebs"
  allow_volume_expansion = true
  reclaim_policy         = "Delete"
  volume_binding_mode    = "WaitForFirstConsumer"
  allowed_topologies {
    match_label_expressions {
      key    = "failure-domain.beta.kubernetes.io/zone"
        values = ["ap-south-1a", "uap-south-1b"]
    }
  }
  parameters = {
    type      = "gp3"
    encrypted = false
    kmsKeyId  = var.aws_kms_key
  }
}


#configure vault
resource "vault_auth_backend" "kubernetes" {
  path = var.cluster_name
  type = "kubernetes"
  tune {
    max_lease_ttl     = "240h0m"
    default_lease_ttl = "240h0m"
  }
}
#install kubernetes service account and cluster role binding
data "kubectl_path_documents" "tokenreview" {
  pattern = "tokenreview.binding.yaml"
}

resource "kubectl_manifest" "tokenreview" {
  count     = length(data.kubectl_path_documents.tokenreview.documents)
  yaml_body = element(data.kubectl_path_documents.tokenreview.documents, count.index)
}

data "kubernetes_service_account_v1" "vault_service_account" {
  depends_on = [kubectl_manifest.tokenreview]
  metadata {
    name      = "vault-tokenreview"
    namespace = "default"
  }
}

data "kubernetes_secret" "vault_service_account" {
  depends_on = [data.kubernetes_service_account_v1.vault_service_account]
  metadata {
    name      = data.kubernetes_service_account_v1.vault_service_account.default_secret_name
    namespace = "default"
  }
}

# Adding backend config to vault auth backend
resource "vault_kubernetes_auth_backend_config" "cluster_config" {
  backend                = vault_auth_backend.kubernetes.path
  kubernetes_host        = data.aws_eks_cluster.cluster.endpoint
  kubernetes_ca_cert     = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token_reviewer_jwt     = data.kubernetes_secret.vault_service_account.data.token
  disable_iss_validation = true
  disable_local_ca_jwt   = false
  pem_keys               = []
  issuer                 = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}
