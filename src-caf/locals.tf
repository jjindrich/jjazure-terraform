locals {
  convention = "cafclassic"
  location   = "westeurope"
  prefix     = "test"
  resource_groups = {
    test = {
      name     = basename(abspath(path.module))
      location = "westeurope"
    },
  }
}
