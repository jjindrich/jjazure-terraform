# JJ Azure automation with Terraform

Terraform intro

- State https://www.terraform.io/intro/getting-started/build.html
- Provisioning https://www.terraform.io/intro/getting-started/provision.html
- Variables
https://www.terraform.io/intro/getting-started/variables.html

Samples https://github.com/terraform-providers/terraform-provider-azurerm/tree/master/examples

## Running locally

Check script [deploy.sh](src-aks\deploy.sh)

## Running in Azure Cloud Shell console

Drag and drop files into cloud shell console

Terraform is automatically authenticated to your azure subscription.

```bash
terraform init
terraform plan
terraform apply -auto-approve
```
