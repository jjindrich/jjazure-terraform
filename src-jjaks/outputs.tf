output "kube_config_raw" {
  value = azurerm_kubernetes_cluster.k8s.kube_admin_config_raw
  sensitive   = true
}

output "config" {
  value = <<CONFIGURE

Run the following commands to configure kubernetes clients:

$ terraform output kube_config_raw
$ bash: terraform output kube_config_raw > ~/.kube/config
$ pwsh: terraform output kube_config_raw > ~\.kube\config

CONFIGURE
}