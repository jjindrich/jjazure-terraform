# create AKS cluster
resource "azurerm_kubernetes_cluster" "k8s" {
  name                = var.cluster_name
  location            = local.location
  resource_group_name = azurerm_resource_group.k8s.name
  dns_prefix          = var.cluster_name
  node_resource_group = var.resource_group_node_name

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

  windows_profile {
    admin_username = "cloudadmin"
    admin_password = data.azurerm_key_vault_secret.node_windows_password.value
  }

  role_based_access_control {
    enabled = true
    azure_active_directory {
      client_app_id = data.azurerm_key_vault_secret.client_id.value
      server_app_id     = data.azurerm_key_vault_secret.spn_id.value
      server_app_secret = data.azurerm_key_vault_secret.spn_secret.value
    }
  }

  service_principal {
    client_id     = data.azurerm_key_vault_secret.spn_id.value
    client_secret = data.azurerm_key_vault_secret.spn_secret.value
  }

  addon_profile {
    kube_dashboard {
      enabled = true
    }
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = data.azurerm_log_analytics_workspace.jjanalytics.id
    }
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }
}

# add Windows nodepool
resource "azurerm_kubernetes_cluster_node_pool" "k8s-npwin" {
  name                  = "npwin"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.k8s.id
  node_count            = 1
  vm_size               = "Standard_B2ms"
  availability_zones    = [1, 2, 3]
  os_type               = "Windows"
  enable_auto_scaling   = true
  min_count             = 1
  max_count             = 3
  vnet_subnet_id        = data.azurerm_subnet.akssubnet.id
  node_taints = [
    "os=windows:NoSchedule"
  ]
  depends_on = [azurerm_kubernetes_cluster.k8s]
}
