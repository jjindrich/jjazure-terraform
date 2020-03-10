# create AKS cluster
resource "azurerm_kubernetes_cluster" "k8s" {
  name                = var.cluster_name
  location            = local.location
  resource_group_name = azurerm_resource_group.k8s.name
  dns_prefix          = var.cluster_name

  default_node_pool {
    name                = "agentpool"
    node_count          = 1
    min_count           = 1
    max_count           = 3
    vm_size             = "Standard_B2s"
    availability_zones  = [1, 2, 3]
    enable_auto_scaling = true
    vnet_subnet_id      = data.azurerm_subnet.akssubnet.id
  }
  /*
  role_based_access_control {
    enabled = true
  }
  */
  service_principal {
    client_id     = data.azurerm_key_vault_secret.spn_id.value
    client_secret = data.azurerm_key_vault_secret.spn_secret.value
  }
  /*
  addon_profile {
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = "${azurerm_log_analytics_workspace.default.id}"
    }
  }
*/
  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }
}
