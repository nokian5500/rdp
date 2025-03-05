var rggroup = $RANDOM
az group create --name rggroup --location eastus
az deployment group create --resource-group rggroup --template-file main.bicep --parameters adminPassword=rggroup
