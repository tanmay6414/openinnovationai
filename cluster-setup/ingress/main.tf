resource "helm_release" "ingresses_helm" {
  name       = "ingress-controller"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.7.5"
  namespace  = "ingress"
  timeout    = "1500"
  values = [
    templatefile(
      "${path.module}/manifests/${each.key}.values.yaml.tpl",
      {
        ssl_cert = var.ssl_cert
      }
    )
  ]
}

# data for fetching the details of the ingress service
data "kubernetes_service" "ingress_service" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress"
  }
}


# to fetch the details of the route53 entry (not the record, but the main entry)
data "aws_route53_zone" "route53_details" {
  name = var.cluster_fqdn
}

# to fetch the details of the ELB, particularly the hosted id and and DNS needed for adding route53 record
data "aws_elb" "ingress_elb" {
  name       = substr(data.kubernetes_service.ingress_service.status.0.load_balancer.0.ingress.0.hostname, 0, 32)
}

# Do failover so no need to manually adding entries again and again not suggested for production
resource "aws_route53_record" "nginx_route53_ingress_record_wildcard" {
  zone_id        = data.aws_route53_zone.route53_details.zone_id
  name           = "*.${var.cluster_fqdn}"
  type           = "A"
  set_identifier = "*-Secondary"

  failover_routing_policy {
    type = "SECONDARY"
  }

  alias {
    name                   = data.aws_elb.ingress_elb.dns_name
    zone_id                = data.aws_elb.ingress_elb.zone_id
    evaluate_target_health = true
  }

  depends_on = [helm_release.ingresses_helm]
}

