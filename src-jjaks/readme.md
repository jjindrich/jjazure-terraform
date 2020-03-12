# JJ Azure - Terraform for AKS

https://docs.microsoft.com/en-us/azure/terraform/terraform-create-k8s-cluster-with-tf-and-aks

Samples

- https://github.com/Azure/terraform/tree/master/quickstart/301-aks-enterprise
- https://github.com/terraform-providers/terraform-provider-azurerm/tree/master/examples/kubernetes
- https://medium.com/@nicolas.yuen/deploying-aks-with-terraform-on-azure-devops-65c7ef95d737
- https://github.com/nyuen/AKS-Articles/tree/master/1-terraform

Helm and TF

- https://blog.dbi-services.com/provisioning-a-aks-cluster-and-kubeinvaders-with-terraform-aks/
- https://learnk8s.io/blog/get-start-terraform-aks
- https://mathieubuisson.github.io/deploying-aks-cluster-psaksdeployment/

```bash
deploy.sh
```

Get Aks credentials

```bash
az aks get-credentials --resource-group jjmicroservices-rg --name jjaks --admin
kubectl config get-contexts
kubectl config set-context jjakstest-admin
kubectl get pods -A
```