// Deploy an Azure Bastion Subnet and Host is a given VNet


@description('The Azure region where the Bastion should be deployed')
param location string = resourceGroup().location

@description('')
param vnetName string

@description('The address prefix to use for the Bastion subnet')
param addressPrefix string = '192.168.250.0/27'

@description('The name of the Bastion public IP address')
param publicIpName string = 'pip-bastion'

@description('The name of the Bastion host')
param bastionHostName string = 'bastion-jumpbox'

// The Bastion Subnet is required to be named 'AzureBastionSubnet'
var subnetName = 'AzureBastionSubnet'

resource bastionSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = {
  name: '${vnetName}/${subnetName}'
  properties: {
    addressPrefix: addressPrefix
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Disabled'
  }
}

resource publicIpAddressForBastion 'Microsoft.Network/publicIpAddresses@2020-08-01' = {
  name: publicIpName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource bastionHost 'Microsoft.Network/bastionHosts@2019-04-01' = {
  name: bastionHostName
  dependsOn: [
    bastionSubnet
    publicIpAddressForBastion
    ]
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          subnet: {
            id: bastionSubnet.id
          }
          publicIPAddress: {
            id: publicIpAddressForBastion.id
          }
        }
      }
    ]
  }
}
