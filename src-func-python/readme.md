# Azure Function running Python custom image

## Create custom image

Docs
- https://docs.microsoft.com/en-us/azure/azure-functions/functions-create-function-linux-custom-image?tabs=in-process%2Cbash%2Cazure-cli&pivots=programming-language-python

```powershell
cd src
az acr build --registry jjakscontainers --image func-python:v1.0.0 .
```

Test it

```powershell
docker run -p 8080:80 -it jjakscontainers.azurecr.io/func-python:v1.0.0

curl http://localhost:8080/api/HttpExample?name=jj
```

