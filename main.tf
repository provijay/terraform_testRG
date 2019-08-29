provider "azurerm" {
  version         = "1.27.0"
  client_id       = "b2e9a570-0e87-409a-83da-87b6b1fd344d"
  client_secret   = "UH0Un5lxJT?H@Y39@Er]E=0FJ6W@86+k"
  tenant_id       = "b4afa8f3-15c1-4194-a107-24285671ac64"
  subscription_id = "81bd7e4d-3615-405c-8586-4021a28fdbcb"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-01"
  location = "West US"
}

resource "azurerm_template_deployment" "test" {
  name                = "acctesttemplate-01"
  resource_group_name = azurerm_resource_group.test.name

  template_body = <<DEPLOY
{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "storageAccountType": {
      "type": "string",
      "defaultValue": "Standard_LRS",
      "allowedValues": [
        "Standard_LRS",
        "Standard_GRS",
        "Standard_ZRS"
      ],
      "metadata": {
        "description": "Storage Account type"
      }
    }
  },
  "variables": {
    "location": "[resourceGroup().location]",
    "storageAccountName": "[concat(uniquestring(resourceGroup().id), 'storage')]",
    "publicIPAddressName": "[concat('myPublicIp', uniquestring(resourceGroup().id))]",
    "publicIPAddressType": "Dynamic",
    "apiVersion": "2015-06-15",
    "dnsLabelPrefix": "terraform-acctest"
  },
  "resources": [
    {
      "type": "Microsoft.Storage/storageAccounts",
      "name": "[variables('storageAccountName')]",
      "apiVersion": "[variables('apiVersion')]",
      "location": "[variables('location')]",
      "properties": {
        "accountType": "[parameters('storageAccountType')]"
      }
    },
    {
      "type": "Microsoft.Network/publicIPAddresses",
      "apiVersion": "[variables('apiVersion')]",
      "name": "[variables('publicIPAddressName')]",
      "location": "[variables('location')]",
      "properties": {
        "publicIPAllocationMethod": "[variables('publicIPAddressType')]",
        "dnsSettings": {
          "domainNameLabel": "[variables('dnsLabelPrefix')]"
        }
      }
    }
  ],
  "outputs": {
    "storageAccountName": {
      "type": "string",
      "value": "[variables('storageAccountName')]"
    }
  }
}
DEPLOY


  # these key-value pairs are passed into the ARM Template's `parameters` block
  parameters = {
    "storageAccountType" = "Standard_GRS"
  }

  deployment_mode = "Incremental"
}

output "storageAccountName" {
  value = azurerm_template_deployment.test.outputs["storageAccountName"]
}

