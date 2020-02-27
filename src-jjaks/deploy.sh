#!/bin/sh
echo "Setting environment variables for Terraform"
tenant=$(az account show -o tsv --query tenantId)
subscription=$(az account show -o tsv --query id)

# az ad sp create-for-rbac -n jjtf --role="Contributor" --scopes="/subscriptions/${subscription}"
clientApplicationId=$(az keyvault secret show --vault-name jjkeyvault --name tfClientApplicationId -o tsv --query value)
clientSecret=$(az keyvault secret show --vault-name jjkeyvault --name tfClientSecret -o tsv --query value)

export ARM_SUBSCRIPTION_ID=$subscription
export ARM_TENANT_ID=$tenant
export ARM_CLIENT_ID=$clientApplicationId
export ARM_CLIENT_SECRET=$clientSecret

# wget https://releases.hashicorp.com/terraform/0.12.21/terraform_0.12.21_linux_amd64.zip
# sudo unzip ./terraform_0.12.21_linux_amd64.zip -d /usr/local/bin/

terraform init
terraform plan

export TF_VAR_client_id=<service-principal-appid>
export TF_VAR_client_secret=<service-principal-password>

terraform apply