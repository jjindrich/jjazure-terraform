# powershell
Write-Output "Setting environment variables for Terraform"
$tenant=$(az account show -o tsv --query tenantId)
$subscription=$(az account show -o tsv --query id)

# az ad sp create-for-rbac -n jjtf --role="Contributor" --scopes="/subscriptions/${subscription}"
$clientApplicationId=$(az keyvault secret show --vault-name jjkeyvault --name tfClientApplicationId -o tsv --query value)
$clientSecret=$(az keyvault secret show --vault-name jjkeyvault --name tfClientSecret -o tsv --query value)

$Env:ARM_SUBSCRIPTION_ID=$subscription
$Env:ARM_TENANT_ID=$tenant
$Env:ARM_CLIENT_ID=$clientApplicationId
$Env:ARM_CLIENT_SECRET=$clientSecret

# https://releases.hashicorp.com/terraform/0.12.23/terraform_0.12.23_windows_amd64.zip

Write-Output "Running Terraform deployment"
terraform init
terraform import azurerm_resource_group.k8s /subscriptions/$subscription/resourceGroups/jjmicroservices-rg
#terraform plan

terraform apply -auto-approve