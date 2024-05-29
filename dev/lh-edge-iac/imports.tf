# # Uncomment the following lines to import the resource group when Arc servers are provisioned by yourself.

 import {
   id = "/subscriptions/bf5f0d72-2171-4e7f-914f-813ce58cbdff/resourceGroups/lh-ashci-edge-iac-rg"
   to = module.base.azurerm_resource_group.rg
 }
