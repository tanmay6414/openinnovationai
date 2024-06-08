
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.30.2"

  cluster_name    = var.cluster_name
  cluster_version = var.kubernetes_version
  vpc_id          = data.terraform_remote_state.network.outputs.vpc_id
  subnet_ids      = data.terraform_remote_state.network.outputs.private_subnets
  prefix_separator                   = ""
  iam_role_name                      = var.cluster_name

  cluster_security_group_name        = var.cluster_name
  cluster_security_group_description = "EKS cluster security group."



  cluster_endpoint_private_access = true # Enable private API endpoint (requests within cluster VPC use this endpoint)
  cluster_addons = {
    coredns = {
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      addon_version     = data.aws_eks_addon_version.coredns.version
      
    }
    kube-proxy = {
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      addon_version     = data.aws_eks_addon_version.kube_proxy.version
    }
    vpc-cni = {
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      version           = data.aws_eks_addon_version.vpc_cni.version
    }
  }
  # Limit public API access to these blocks
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs

  tags = merge(var.aws_default_tags, { Name = var.cluster_name })

  
  create_cloudwatch_log_group = false

  eks_managed_node_groups = {
    app-tier = {
        ami_type                              = "AL2_x86_64"
        attach_cluster_primary_security_group = true
        block_device_mappings                 = {
            xvda = {
                device_name = "/dev/xvda"
                ebs         = {
                    volume_size = 40
                    volume_type = "gp3"
                }
            }
        }
        capacity_type                         = "ON_DEMAND"
        create_security_group                 = false
        desired_size                          = 1
        iam_role_additional_policies          = [
            "arn:aws:iam::768688893088:policy/TestCluster-autoscaler",
        ]
        instance_types                        = [
            "r5a.xlarge",
        ]
        key_name                              = "${var.cluster_name}-worker"
        labels                                = {
            Environment = var.cluster_name
            tier        = "app"
        }
        max_size                              = 10
        min_size                              = 0
        pre_bootstrap_user_data               = ""
        subnet_ids                            = data.terraform_remote_state.network.outputs.private_subnets
        tags                                  = {
            Name = "app-tier"
            Tier = "app-tier"
        }
        taints                                = []
    }
  }


  node_security_group_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = null
    "KubernetesCluster"                         = null
  }
}
