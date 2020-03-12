locals {
  location = "westeurope"
  network_reference = {
    network_name        = "JJDevV2NetworkApp"
    subnet_name         = "DmzAks"
    resource_group_name = "JJDevV2-Infra"
  }
  monitoring = {
    analytics_name      = "jjdev-analytics"
    resource_group_name = "jjdevmanagement"
  }
}
