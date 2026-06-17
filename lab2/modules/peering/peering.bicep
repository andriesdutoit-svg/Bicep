targetScope = 'subscription'

param peerings array

// A → B
resource peerAtoB 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-07-01' = [
  for p in peerings: {
    name: '${p.vnetAName}/${p.vnetAName}-to-${p.vnetBName}-peering'
    
    scope: resourceGroup(p.rgA)

    properties: {
      remoteVirtualNetwork: {
        id: p.vnetBId
      }
      allowVirtualNetworkAccess: true
      allowForwardedTraffic: true
      allowGatewayTransit: false
      useRemoteGateways: false
    }
  }
]

// B → A
resource peerBtoA 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-07-01' = [
  for p in peerings: {
    name: '${p.vnetBName}/${p.vnetBName}-to-${p.vnetAName}-peering'
    
    scope: resourceGroup(p.rgB)

    properties: {
      remoteVirtualNetwork: {
        id: p.vnetAId
      }
      allowVirtualNetworkAccess: true
      allowForwardedTraffic: true
      allowGatewayTransit: false
      useRemoteGateways: false
    }
  }
]
