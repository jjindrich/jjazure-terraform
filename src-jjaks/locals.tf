locals {
  location = "westeurope"
  network_reference = {
    network_name        = "jjazappvnet"
    subnet_name         = "aks-snet"
    resource_group_name = "jjnetwork-rg"
  }
  monitoring = {
    analytics_name      = "jjazworkspace"
    resource_group_name = "jjinfra-rg"
  }
}
