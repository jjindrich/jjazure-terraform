output "kube_config_raw" {
  value = azurerm_kubernetes_cluster.k8s.kube_config_raw
  sensitive   = true
}

output "kube_fqdn" {
  value = azurerm_kubernetes_cluster.k8s.fqdn
  sensitive   = false
}

output "config" {
  value = <<CONFIGURE

Run the following commands to configure kubernetes clients:

$ terraform output kube_config_raw
$ bash: terraform output kube_config_raw > ~/.kube/config
$ pwsh: terraform output kube_config_raw > ~\.kube\config

CONFIGURE
}