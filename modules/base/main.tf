resource "azurerm_resource_group" "rg" {
  depends_on = [
    data.external.aksIpCheck
  ]
  name     = local.resourceGroupName
  location = var.location
  tags = {
    siteId = var.siteId
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

module "site-manager" {
  source              = "../site-manager"
  siteResourceName    = local.siteResourceName
  siteDisplayName     = local.siteDisplayName
  addressResourceName = local.addressResourceName
  resourceGroup       = azurerm_resource_group.rg
  country             = var.country
  city                = var.city
  companyName         = var.companyName
  postalCode          = var.postalCode
  stateOrProvince     = var.stateOrProvince
  streetAddress1      = var.streetAddress1
  streetAddress2      = var.streetAddress2
  streetAddress3      = var.streetAddress3
  zipExtendedCode     = var.zipExtendedCode
  contactName         = var.contactName
  emailList           = var.emailList
  mobile              = var.mobile
  phone               = var.phone
  phoneExtension      = var.phoneExtension
}

//Prepare AD and arc server
module "hci-provisioners" {
  depends_on             = [azurerm_resource_group.rg]
  count                  = var.enableProvisioners ? 1 : 0
  source                 = "../hci-provisioners"
  resourceGroup          = azurerm_resource_group.rg
  siteId                 = var.siteId
  domainFqdn             = var.domainFqdn
  adouPath               = local.adouPath
  domainServerIP         = var.domainServerIP
  domainAdminUser        = var.domainAdminUser
  domainAdminPassword    = var.domainAdminPassword
  authenticationMethod   = var.authenticationMethod
  servers                = var.servers
  clusterName            = local.clusterName
  subscriptionId         = var.subscriptionId
  localAdminUser         = var.localAdminUser
  localAdminPassword     = var.localAdminPassword
  deploymentUser         = local.deploymentUserName
  deploymentUserPassword = var.deploymentUserPassword
  servicePrincipalId     = var.servicePrincipalId
  servicePrincipalSecret = var.servicePrincipalSecret
  destory_adou           = var.destory_adou
  virtualHostIp          = var.virtualHostIp
  dcPort                 = var.dcPort
  serverPorts            = var.serverPorts
}

module "hci" {
  depends_on                    = [module.hci-provisioners]
  source                        = "../hci"
  resourceGroup                 = azurerm_resource_group.rg
  siteId                        = var.siteId
  domainFqdn                    = var.domainFqdn
  subnetMask                    = var.subnetMask
  startingAddress               = var.startingAddress
  endingAddress                 = var.endingAddress
  defaultGateway                = var.defaultGateway
  dnsServers                    = var.dnsServers
  adouPath                      = local.adouPath
  servers                       = var.servers
  managementAdapters            = var.managementAdapters
  storageNetworks               = var.storageNetworks
  rdmaEnabled                   = var.rdmaEnabled
  storageConnectivitySwitchless = var.storageConnectivitySwitchless
  clusterName                   = local.clusterName
  customLocationName            = local.customLocationName
  witnessStorageAccountName     = local.witnessStorageAccountName
  keyvaultName                  = local.keyvaultName
  randomSuffix                  = local.randomSuffix
  subscriptionId                = var.subscriptionId
  deploymentUser                = local.deploymentUserName
  deploymentUserPassword        = var.deploymentUserPassword
  localAdminUser                = var.localAdminUser
  localAdminPassword            = var.localAdminPassword
  servicePrincipalId            = var.servicePrincipalId
  servicePrincipalSecret        = var.servicePrincipalSecret
  rpServicePrincipalObjectId    = var.rpServicePrincipalObjectId
}

locals {
  serverNames = [for server in var.servers : server.name]
}

module "extension" {
  source                     = "../hci-extensions"
  depends_on                 = [module.hci]
  resourceGroup              = azurerm_resource_group.rg
  siteId                     = var.siteId
  arcSettingsId              = module.hci.arcSettings.id
  serverNames                = local.serverNames
  workspaceName              = local.workspaceName
  dataCollectionEndpointName = local.dataCollectionEndpointName
  dataCollectionRuleName     = local.dataCollectionRuleName
  enableInsights             = var.enableInsights
  enableAlerts               = var.enableAlerts
}

module "vm" {
  count            = var.enableVM ? 1 : 0
  source           = "../hci-vm"
  depends_on       = [module.hci]
  customLocationId = module.hci.customlocation.id
  resourceGroupId  = azurerm_resource_group.rg.id
  userStorageId    = module.hci.userStorages[0].id
  location         = azurerm_resource_group.rg.location
}

module "aks-arc" {
  source                  = "../aks-arc"
  depends_on              = [module.hci]
  customLocationId        = module.hci.customlocation.id
  resourceGroup           = azurerm_resource_group.rg
  agentPoolProfiles       = var.agentPoolProfiles
  sshKeyVaultId           = module.hci.keyvault.id
  startingAddress         = var.aksArc-lnet-startingAddress
  endingAddress           = var.aksArc-lnet-endingAddress
  dnsServers              = var.aksArc-lnet-dnsServers == [] ? var.dnsServers : var.aksArc-lnet-dnsServers
  defaultGateway          = var.aksArc-lnet-defaultGateway == "" ? var.defaultGateway : var.aksArc-lnet-defaultGateway
  addressPrefix           = var.aksArc-lnet-addressPrefix
  logicalNetworkName      = local.logicalNetworkName
  aksArcName              = local.aksArcName
  vlanId                  = var.aksArc-lnet-vlanId
  controlPlaneIp          = var.aksArc-controlPlaneIp
  arbId                   = module.hci.arcbridge.id
  kubernetesVersion       = var.kubernetesVersion
  controlPlaneCount       = var.controlPlaneCount
  rbacAdminGroupObjectIds = var.rbacAdminGroupObjectIds
}
