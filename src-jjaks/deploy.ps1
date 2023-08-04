# powershell
Write-Output "Setting environment variables for Terraform"
#$Env:TF_LOG="debug"

Write-Output "Check Terraform syntax"
terraform fmt -check

Write-Output "Running Terraform deployment"
#terraform init -upgrade
terraform init

#terraform plan -var aks_first_deployment=false

terraform apply -auto-approve -var aks_first_deployment=true
terraform apply -auto-approve -var aks_first_deployment=false

#terraform destroy -auto-approve