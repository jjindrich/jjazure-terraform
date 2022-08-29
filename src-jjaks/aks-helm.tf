# Load Provider Helm and helm stable repository
provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.k8s.kube_admin_config.0.host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.k8s.kube_admin_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.k8s.kube_admin_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.k8s.kube_admin_config.0.cluster_ca_certificate)
  }
}

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.k8s.kube_admin_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.k8s.kube_admin_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.k8s.kube_admin_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.k8s.kube_admin_config.0.cluster_ca_certificate)
  experiments { manifest_resource = true }
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
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  timeout    = 2400
  namespace  = kubernetes_namespace.nginx_ingress.metadata.0.name
  set {
    name  = "replicaCount"
    value = "1"
  }
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-dns-label-name"
    value = var.cluster_name
  }
  set {
    name  = "extraEnvs[0].name"
    value = "KUBERNETES_SERVICE_HOST"
  }
  set {
    name  = "extraEnvs[0].value"
    value = azurerm_kubernetes_cluster.k8s.fqdn
  }
  depends_on = [kubernetes_namespace.nginx_ingress]
}

# Install nginx ingress controller Internal
# docs https://docs.nginx.com/nginx-ingress-controller/installation/installation-with-helm/
resource "kubernetes_namespace" "nginx_ingress_internal" {
  metadata {
    name = "ingress-basic-internal"
  }
  depends_on = [azurerm_kubernetes_cluster.k8s, azurerm_role_assignment.k8s-rbac-network]
}
resource "helm_release" "nginx_ingress_internal" {
  name       = "nginx-ingress-internal"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  timeout    = 2400
  namespace  = kubernetes_namespace.nginx_ingress_internal.metadata.0.name
  set {
    name  = "replicaCount"
    value = "1"
  }
  set {
    name  = "controller.service.loadBalancerIP"
    value = var.ingress_load_balancer_ip
  }
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-internal"
    value = "true"
  }
  set {
    name  = "controller.ingressClassResource.name"
    value = "nginx-internal"
  }
  set {
    name  = "extraEnvs[0].name"
    value = "KUBERNETES_SERVICE_HOST"
  }
  set {
    name  = "extraEnvs[0].value"
    value = azurerm_kubernetes_cluster.k8s.fqdn
  }
  depends_on = [kubernetes_namespace.nginx_ingress_internal]
}

# Install LetsEncrypt Cluster Manager
# BUG: nejdrive je potreba zkusit instalaci rucne, pak to projde - https://docs.microsoft.com/en-us/azure/aks/ingress-tls?tabs=azure-powershell
resource "kubernetes_namespace" "cert-manager" {
  metadata {
    name = "cert-manager"
  }
  depends_on = [azurerm_kubernetes_cluster.k8s]
}
resource "helm_release" "cert-manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  timeout    = 2400
  namespace  = kubernetes_namespace.cert-manager.metadata.0.name
  version = "v1.7.1"
  set {
    name  = "installCRDs"
    value = "true"
  }
  depends_on = [kubernetes_namespace.cert-manager]
}
resource "kubernetes_manifest" "clusterissuer_letsencrypt_prod" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind" = "ClusterIssuer"
    "metadata" = {
      "name" = "letsencrypt-prod"
    }
    "spec" = {
      "acme" = {
        "email" = "jajindri@microsoft.com"
        "privateKeySecretRef" = {
          "name" = "letsencrypt-prod"
        }
        "server" = "https://acme-v02.api.letsencrypt.org/directory"
        "solvers" = [
          {
            "http01" = {
              "ingress" = {
                "class" = "nginx"
              }
            }
          },
        ]
      }
    }
  }
  depends_on = [helm_release.cert-manager]
}