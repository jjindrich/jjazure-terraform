provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "k8s" {
  name     = var.resource_group_name
  location = "westeurope"
}

resource "azurerm_kubernetes_cluster" "k8s" {
  name                = var.cluster_name
  location            = azurerm_resource_group.k8s.location
  resource_group_name = azurerm_resource_group.k8s.name
  dns_prefix          = var.dns_prefix

  linux_profile {
    admin_username = "ubuntu"

    ssh_key {
      key_data = file(var.ssh_public_key)
    }
  }

  default_node_pool {
    name                = "agentpool"
    node_count          = 1
    vm_size             = "Standard_B2s"
    availability_zones  = [1, 2, 3]
    enable_auto_scaling = trure
    vnet_subnet_id      = "${var.vnet_subnet_id}"
  }

  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }

  addon_profile {
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = var.log_analytics_workspace_id
    }
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }
}
