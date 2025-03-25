# Use Terraform wiht Azure Verified Modules

What is AVM https://azure.github.io/Azure-Verified-Modules/overview/introduction/

Modules https://azure.github.io/Azure-Verified-Modules/indexes/terraform/

## Create IaC

Quickstart https://azure.github.io/Azure-Verified-Modules/usage/quickstart/terraform/

Copy example from Resource or Pattern module
Copy module reference into file


## Deploy

Many AVM modules requires subscription_id variable as env or setup in provider section
```pwsh
$env:ARM_SUBSCRIPTION_ID="<your subscription guid>"
```

```pwsh
terraform init
terraform apply
```