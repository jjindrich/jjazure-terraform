# namespaces for JJWeb application
resource "kubernetes_namespace" "jjweb-ns" {
  metadata {
    name = "jjweb"
  }
  depends_on = [azurerm_kubernetes_cluster.k8s]
}
resource "kubernetes_namespace" "jjapi-ns" {
  metadata {
    name = "jjapi"
  }
  depends_on = [azurerm_kubernetes_cluster.k8s]
}