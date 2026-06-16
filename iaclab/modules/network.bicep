param location string
param vnetName string
param vnetAddressSpace string
param subnetName string
param subnetAddressSpace string

resource vnet 'Microsoft.Network/virtualNetworks@2023-02-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressSpace
      ]
    }
  }
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-02-01' = {
  name: subnetName
  parent: vnet
  properties: {
    addressPrefix: subnetAddressSpace
  }
}

output subnetId string = subnet.id
