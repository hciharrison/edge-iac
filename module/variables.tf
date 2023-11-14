variable "location" {
  default     = "eastus"
  type        = string
  description = "The Azure region where the resources will be deployed."
}

variable "rp_principal_id" {
  default     = "f0e0e122-3f80-44ed-95d2-f56e6fdc514c"
  type        = string
  description = "The principal ID of the resource provider."
}

variable "siteId" {
  type        = string
  description = "A unique identifier for the site."
}

variable "servers" {
  description = "A list of servers with their names and IPv4 addresses."
  type = list(object({
    name        = string
    ipv4Address = string
  }))
}

variable "domainServerIP" {
  description = "The ip of the domain server."
  type = string
}

variable "domainName" {
  description = "The domain name for the environment."
  type        = string
}

variable "destory_adou" {
  description = "whether destroy previous adou"
  default = false
  type        = bool
}

variable "domainAdminUser" {
  sensitive   = true
  type        = string
  description = "The username for the domain administrator account."
}

variable "domainAdminPassword" {
  sensitive   = true
  type        = string
  description = "The password for the domain administrator account."
}

variable "localAdminUser" {
  sensitive   = true
  type        = string
  description = "The username for the local administrator account."
}

variable "localAdminPassword" {
  sensitive   = true
  type        = string
  description = "The password for the local administrator account."
}

//deploymentSettings related variables  
variable "domainFqdn" {
  description = "The domain FQDN."
  type        = string
}

variable "subnetMask" {
  default     = "255.255.255.0"
  type        = string
  description = "The subnet mask for the network."
}

variable "startingAddress" {
  description = "The starting IP address of the IP address range."
  type        = string
}

variable "endingAddress" {
  description = "The ending IP address of the IP address range."
  type        = string
}

variable "defaultGateway" {
  description = "The default gateway for the network."
  type        = string
}

variable "dnsServers" {
  type        = list(string)
  description = "A list of DNS server IP addresses."
}

variable "adouPath" {
  type        = string
  description = "The Active Directory OU path."
}

variable "subId" {
  type        = string
  description = "The subscription ID for the Azure account."
}

variable "tenant" {
  type        = string
  description = "The tenant ID for the Azure account."
}

variable "servicePricipalId" {
  type        = string
  sensitive   = true
  description = "The service principal ID for the Azure account."
}

variable "servicePricipalSecret" {
  type        = string
  sensitive   = true
  description = "The service principal secret for the Azure account."
}