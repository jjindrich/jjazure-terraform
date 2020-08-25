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

$subscription_spoke="c96358c2-e8a3-43ed-89c6-add1aaa99441"

# https://releases.hashicorp.com/terraform/0.12.23/terraform_0.12.23_windows_amd64.zip

Write-Output "Running Terraform deployment"
terraform init
#terraform plan -var "subscriptionid_hub=$subscription" -var "subscriptionid_spoke=$subscription_spoke"

terraform apply -var "subscriptionid_hub=$subscription" -var "subscriptionid_spoke=$subscription_spoke" -auto-approve

#terraform destroy -var "subscriptionid_hub=$subscription" -var "subscriptionid_spoke=$subscription_spoke"