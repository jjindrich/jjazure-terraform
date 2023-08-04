# create AKS cluster
resource "azurerm_kubernetes_cluster" "k8s" {
  name                = var.cluster_name
  location            = local.location
  resource_group_name = azurerm_resource_group.k8s.name
  dns_prefix          = var.cluster_name
  # node_resource_group = var.resource_group_node_name
  # kubernetes_version  = "1.24.6"
  automatic_channel_upgrade = "patch"

  default_node_pool {
    name                = "agentpool"
    min_count           = 1
    max_count           = 5
    vm_size             = "Standard_B2s"
    zones               = [1, 2, 3]
    enable_auto_scaling = true
    vnet_subnet_id      = data.azurerm_subnet.akssubnet.id
    #scale_down_mode     = "Deallocate"
  }

  azure_active_directory_role_based_access_control {
    managed            = true
    azure_rbac_enabled = true
  }

  identity {
    type = "SystemAssigned"
  }

  azure_policy_enabled = true
  oms_agent {
    log_analytics_workspace_id = data.azurerm_log_analytics_workspace.jjanalytics.id
    msi_auth_for_monitoring_enabled = true
  }

  monitor_metrics {}

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }
}
/*
# add Windows nodepool
resource "azurerm_kubernetes_cluster_node_pool" "k8s-npwin" {
  name                  = "npwin"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.k8s.id
  vm_size               = "Standard_B2ms"
  zones                 = [1, 2, 3]
  os_type               = "Windows"
  // not possible to use Windows2022 now
  //os_sku                = "Windows2022"
  // workaround: 
  //   az aks nodepool add --resource-group jjmicroservices-rg --cluster-name jjazaks --name npwin --os-sku Windows2022 --os-type Windows --node-vm-size Standard_B2ms --zones 1 2 3 --node-taints os=windows:NoSchedule  
  //   terraform import azurerm_kubernetes_cluster_node_pool.k8s-npwin /subscriptions/XXXXXXXXXXXXXXX/resourceGroups/jjmicroservices-rg/providers/Microsoft.ContainerService/managedClusters/jjazaks/agentPools/npwin
  workload_runtime      = "OCIContainer"
  enable_auto_scaling   = true
  min_count             = 1
  max_count             = 3
  vnet_subnet_id        = data.azurerm_subnet.akssubnet.id
  scale_down_mode       = "Deallocate"
  node_taints = [
    "os=windows:NoSchedule"
  ]
  depends_on = [azurerm_kubernetes_cluster.k8s]
}
*/
# permission to join K8s to virtual network
resource "azurerm_role_assignment" "k8s-rbac-network" {
  scope                = data.azurerm_resource_group.rg-network.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.k8s.identity[0].principal_id
}

# permission to access ACR
resource "azurerm_role_assignment" "k8s-rbac-acr" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.k8s.identity[0].principal_id
}
resource "azurerm_role_assignment" "k8s-kubelet-rbac-acr" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.k8s.kubelet_identity[0].object_id
}

# configure monitoring
resource "azurerm_monitor_data_collection_endpoint" "aks-endpoint" {
  name                          = "${var.cluster_name}-metrics-endpoint"
  resource_group_name           = azurerm_resource_group.k8s.name
  location                      = local.location
  kind                          = "Linux"
  public_network_access_enabled = true
}
resource "azurerm_monitor_data_collection_rule" "aks-rule-prometheus" {
  name                        = "${var.cluster_name}-metrics-rule"
  resource_group_name         = azurerm_resource_group.k8s.name
  location                    = local.location
  data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.aks-endpoint.id

  destinations {
    monitor_account {
      monitor_account_id = azurerm_monitor_workspace.jjprometheus.id
      name               = "MonitoringAccount1"
    }
  }

  data_flow {
    streams      = ["Microsoft-PrometheusMetrics"]
    destinations = ["MonitoringAccount1"]
  }

  data_sources {
    prometheus_forwarder {
      name    = "PrometheusDataSource"
      streams = ["Microsoft-PrometheusMetrics"]
    }
  }
}
resource "azurerm_monitor_data_collection_rule_association" "aks-rule-association" {
  name                        = var.cluster_name
  target_resource_id          = azurerm_kubernetes_cluster.k8s.id
  data_collection_rule_id     = azurerm_monitor_data_collection_rule.aks-rule-prometheus.id
}

## TODO: add prometheus and grafana configuration
# https://github.com/tkubica12/azure-workshops/blob/main/d-aks/terraform/monitoring.tf