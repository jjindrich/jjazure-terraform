# Load Provider Helm and helm stable repository
provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.k8s.kube_config.0.host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate)
  }
}
data "helm_repository" "stable" {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com"
}

# Install nginx ingress controller
resource "kubernetes_namespace" "nginx_ingress" {
  metadata {
    name = "ingress-basic"
  }
  depends_on = [azurerm_kubernetes_cluster.k8s]
}
resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  repository = data.helm_repository.stable.metadata[0].name
  chart      = "stable/nginx-ingress"
  timeout    = 2400
  namespace  = kubernetes_namespace.nginx_ingress.metadata.0.name
  set {
    name  = "controller.replicaCount"
    value = "1"
  }
  depends_on = [kubernetes_cluster_role_binding.tiller]
}

# Install nginx ingress controller Internal
resource "kubernetes_namespace" "nginx_ingress_internal" {
  metadata {
    name = "ingress-basic-internal"
  }
  depends_on = [azurerm_kubernetes_cluster.k8s]
}
resource "helm_release" "nginx_ingress_internal" {
  name       = "nginx-ingress-internal"
  repository = data.helm_repository.stable.metadata[0].name
  chart      = "stable/nginx-ingress"
  timeout    = 2400
  namespace  = kubernetes_namespace.nginx_ingress_internal.metadata.0.name
  values = [<<EOF
controller:
  ingressClass: nginx-internal
  replicaCount: 1
  service:
    loadBalancerIP: ${var.ingress_load_balancer_ip}
    annotations:
      service.beta.kubernetes.io/azure-load-balancer-internal: "true"
      kubernetes.io/ingress.class: nginx-internal
EOF
  ]
  depends_on = [kubernetes_cluster_role_binding.tiller]
}