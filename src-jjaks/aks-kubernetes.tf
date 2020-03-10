# Load Provider K8s
provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.k8s.kube_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate)
  alias                  = "aks-ci"
}

# Create tiller service account and cluster role binding
resource "kubernetes_service_account" "tiller" {
  metadata {
    name      = "tiller"
    namespace = "kube-system"
  }
  automount_service_account_token = true
  depends_on                      = [azurerm_kubernetes_cluster.k8s]
}
resource "kubernetes_cluster_role_binding" "tiller" {
  metadata {
    name = "tiller"
  }
  role_ref {
    kind      = "ClusterRole"
    name      = "cluster-admin"
    api_group = "rbac.authorization.k8s.io"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.tiller.metadata.0.name
    api_group = ""
    namespace = "kube-system"
  }
  depends_on = [kubernetes_service_account.tiller]
}

# Grant cluster-admin rights to the AAD role
resource "kubernetes_cluster_role_binding" "default" {
  metadata {
    name = "default"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Group"
    name      = var.aad_aks_admin_role
  }
}

# Grant cluster-admin rights to the kubernetes-dashboard account
resource "kubernetes_cluster_role_binding" "dashboard" {
  metadata {
    name = "kubernetes-dashboard"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "kubernetes-dashboard"
    namespace = "kube-system"
  }
}

# Save kube-config into azure_config file
/*
resource "null_resource" "save-kube-config" {
  triggers = {
    config = "${azurerm_kubernetes_cluster.k8s.kube_config_raw}"
  }
  provisioner "local-exec" {
    command = "mkdir -p ${path.module}/.kube && echo '${azurerm_kubernetes_cluster.k8s.kube_config_raw}' > ${path.module}/.kube/azure_config && chmod 0600 ${path.module}/.kube/azure_config"
  }
  depends_on = [azurerm_kubernetes_cluster.k8s]
}
*/