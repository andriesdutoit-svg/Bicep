// Define existing VNets across RGs

var pairs = [
  {
    vnetA: 'lab1-vnet-wus2'
    rgA: 'lab1-rg-wus2'
    vnetB: 'lab1-vnet-krs'
    rgB: 'lab1-rg-krs'
  }
  {
    vnetA: 'lab1-vnet-wus2'
    rgA: 'lab1-rg-wus2'
    vnetB: 'lab1-vnet-sdc'
    rgB: 'lab1-rg-sdc'
  }
  {
    vnetA: 'lab1-vnet-krs'
    rgA: 'lab1-rg-krs'
    vnetB: 'lab1-vnet-sdc'
    rgB: 'lab1-rg-sdc'
  }
]

// Loop peering
resource peerings 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-07-01' = [for pair in pairs: {
  name: '${pair.vnetA}-to-${pair.vnetB}'
  scope: resourceGroup(pair.rgA)
  properties: {
    remoteVirtualNetwork: {
      id: resourceId(pair.rgB, 'Microsoft.Network/virtualNetworks', pair.vnetB)
    }
    allowVirtualNetworkAccess: true
  }
}]
