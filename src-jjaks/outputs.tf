output "kube_config_raw" {
  value = azurerm_kubernetes_cluster.k8s.kube_config_raw
  sensitive   = true
}

output "config" {
  value = <<CONFIGURE

Run the following commands to configure kubernetes clients:

$ terraform output kube_config_raw > ~/.kube/aksconfig
$ export KUBECONFIG=~/.kube/aksconfig

CONFIGURE

}