locals {
  location = "germanywestcentral"
  network_reference = {
    network_name        = "jjazgwappvnet"
    subnet_name         = "aks-snet"
    resource_group_name = "jjnetwork-gw-rg"
  }
  monitoring = {
    analytics_name      = "jjazgwworkspace"
    resource_group_name = "jjinfra-gw-rg"
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
