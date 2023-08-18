# namespaces for JJWeb application
resource "kubernetes_namespace" "jjweb-ns" {
  metadata {
    name = "jjweb"
  }
  lifecycle {
    ignore_changes = [
      metadata,
    ]
  }
  depends_on = [azurerm_kubernetes_cluster.k8s]
}
resource "kubernetes_namespace" "jjapi-ns" {
  metadata {
    name = "jjapi"
  }
  lifecycle {
    ignore_changes = [
      metadata,
    ]
  }
  depends_on = [azurerm_kubernetes_cluster.k8s]
}
