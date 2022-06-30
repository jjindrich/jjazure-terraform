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

$acr_password=$(az acr credential show -n jjakscontainers -o tsv --query passwords[0].value)

Write-Output "Check Terraform syntax"
terraform fmt -check

Write-Output "Running Terraform deployment"
terraform init
#terraform plan

terraform apply -auto-approve -var acr_password=$acr_password

#terraform destroy -auto-approve