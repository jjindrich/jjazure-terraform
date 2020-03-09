# Azure Cloud Adoption Framework

Framework CAF - http://aka.ms/caf

Project Terraform CAF - https://github.com/aztfmod

Landing zones - https://github.com/aztfmod/landingzones

Prepared modules - https://registry.terraform.io/modules/aztfmod

## Create new resource with naming convention

It loads *.auto.tfvars file for variables automatically.

```bash
terraform init
terraform plan

terraform apply -auto-approve
```

It creates new resource group named by foldername and storage account with name automatically generated.