terraform {
  backend "azurerm" {
    resource_group_name  = "lh-ashci-edge-iac-rg"
    storage_account_name = "edgeiacsa01"
    container_name       = "backend"
    key                  = "sample.tfstate"
  }
}
