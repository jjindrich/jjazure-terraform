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
  keyvault_reference = {
    keyvault_name       = "jjazkeyvault"
    resource_group_name = "jjinfra-rg"
  }
  appdeploy_identity_reference = {
    identity_name       = "jjazidentity-github-app"
    resource_group_name = "jjinfra-rg"
  }
}
