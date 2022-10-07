# powershell
Write-Output "Setting environment variables for Terraform"
#$Env:TF_LOG="debug"

# https://releases.hashicorp.com/terraform/0.12.23/terraform_0.12.23_windows_amd64.zip

Write-Output "Check Terraform syntax"
terraform fmt -check

Write-Output "Running Terraform deployment"
terraform init

#terraform plan

#terraform apply -auto-approve -var aks_first_deployment=true
terraform apply -auto-approve -var aks_first_deployment=false

#terraform destroy -auto-approve