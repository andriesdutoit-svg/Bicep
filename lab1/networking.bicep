param vnetName string
param addressPrefix string
param subnetPrefix string

resource nsg 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: '${vnetName}-nsg'
  location: resourceGroup().location
  properties: {
    securityRules: [
      {
        name: 'Allow-AD'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: '*'
          sourceAddressPrefix: '10.0.0.0/8'
          destinationPortRanges: [
            '53'
            '88'
            '389'
            '445'
            '135'
            '3389'
            '49152-65535'
          ]
        }
      }
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: vnetName
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [addressPrefix]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: subnetPrefix
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
    ]
  }
}
