provider "azurerm" {
  features {}
}

# refer to existing resources
data "azurerm_subnet" "akssubnet" {
  name                 = "DmzAks"
  virtual_network_name = "JJDevV2NetworkApp"
  resource_group_name  = "JJDevV2-Infra"
}
data "azurerm_key_vault" "jjkeyvault" {
  name                = "${var.keyvault_name}"
  resource_group_name = "${var.keyvault_rg}"
}
data "azurerm_key_vault_secret" "spn_id" {
  name         = "tfClientApplicationId"
  key_vault_id = "${data.azurerm_key_vault.jjkeyvault.id}"
}
data "azurerm_key_vault_secret" "spn_secret" {
  name         = "tfClientSecret"
  key_vault_id = "${data.azurerm_key_vault.jjkeyvault.id}"
}

resource "azurerm_resource_group" "k8s" {
  name     = "${var.resource_group_name}"
  location = "westeurope"
}

# create AKS cluster
resource "azurerm_kubernetes_cluster" "k8s" {
  name                = "${var.cluster_name}"
  location            = "westeurope"
  resource_group_name = "${azurerm_resource_group.k8s.name}"
  dns_prefix          = "${var.cluster_name}"

  default_node_pool {
    name                = "agentpool"
    node_count          = 1
    min_count           = 1
    max_count           = 3
    vm_size             = "Standard_B2s"
    availability_zones  = [1, 2, 3]
    enable_auto_scaling = true
    vnet_subnet_id      = "${data.azurerm_subnet.akssubnet.id}"
  }

  service_principal {
    client_id     = "${data.azurerm_key_vault_secret.spn_id.value}"
    client_secret = "${data.azurerm_key_vault_secret.spn_secret.value}"
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }
}
