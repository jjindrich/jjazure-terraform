# JJ Azure automation with Terraform

https://docs.microsoft.com/en-us/azure/virtual-machines/linux/terraform-create-complete-vm?toc=%2Fen-us%2Fazure%2Fterraform%2Ftoc.json&bc=%2Fen-us%2Fazure%2Fbread%2Ftoc.json



## Running in Azure Cloud Shell console
Drag and drop files into cloud shell console

Terraform is automatically authenticated to your azure subscription.

```bash
teraform init
teraform plan
teraform apply
```

## Attach OS disk
from Restore / from snapshot

https://stackoverflow.com/questions/48169338/terraform-launching-an-azure-virtual-machine-from-a-snapshot