# JJ Azure automation with Terraform

Terraform intro

- State https://www.terraform.io/intro/getting-started/build.html
- Provisioning https://www.terraform.io/intro/getting-started/provision.html
- Variables
https://www.terraform.io/intro/getting-started/variables.html

Samples https://github.com/terraform-providers/terraform-provider-azurerm/tree/master/examples

## Terraform and Azure Cloud Adoption Framework

Reuse existing resources from **Azure Cloud Adoption Framework**. Check this [repo](src-caf\readme.md).

## Terraform and Azure Kubernetes Service AKS

Setup your AKS deployment with Terraform. Check this [repo](src-aks\readme.md).

## Running Terraform in Azure Cloud Shell console

Drag and drop files into Azure Cloud shell console. 

Terraform is automatically installed and authenticated to your Azure subscription.

```bash
terraform init
terraform plan
terraform apply -auto-approve
```
