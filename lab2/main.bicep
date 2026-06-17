targetScope = 'subscription'
@description('Prefix for all resources')
param prefix string = 'lab2'
@description('Tags applied to all resources')
param tags object

param adminUsername string
@secure()
param adminPassword string

param vmSize string
param osDisk object

param regions object

param dc01RegionKey string
param dc02RegionKey string
param dc03RegionKey string
param dc04RegionKey string
param dc05RegionKey string
param windowsClient01RegionKey string
param windowsClient02RegionKey string
param ubuntu01RegionKey string
param ubuntu02RegionKey string
param ubuntu03RegionKey string

param windowsServerImage object
param windowsClientImage object
param ubuntuImage object

param externalAccessPrefixes array = []

//
// RESOURCE GROUPS
//
resource rgs 'Microsoft.Resources/resourceGroups@2022-09-01' = [
  for regionKey in keys(regions): {
    name: '${prefix}-rg-${regionKey}'
    location: regions[regionKey]
    tags: tags
  }
]

//
// VNets
//
module vnets 'modules/networking/vnet.bicep' = [
  for (regionKey, i) in items(regions): {
    name: 'vnet-${regionKey}'
    scope: resourceGroup('${prefix}-rg-${regionKey}')
    params: {
      vnetName: '${prefix}-vnet-${regionKey}'
      location: regions[regionKey]
      addressPrefix: '10.${i}.0.0/16'
      subnetPrefix: '10.${i}.0.0/24'
      dnsServers: []
      tags: tags
      externalAccessPrefixes: externalAccessPrefixes
    }
  }
]

//
// BUILD PEERING MAP
//

// Convert regions into a usable indexed list
var regionList = items(regions)

// Build all unique VNet peering pairs (full mesh)
var peeringPairs = [
  for i in range(0, length(regionList)): [
    for j in range(i + 1, length(regionList)): {

      vnetAName: '${prefix}-vnet-${regionList[i].key}'
      vnetBName: '${prefix}-vnet-${regionList[j].key}'

      vnetAId: resourceId(
        subscription().subscriptionId,
        '${prefix}-rg-${regionList[i].key}',
        'Microsoft.Network/virtualNetworks',
        '${prefix}-vnet-${regionList[i].key}'
      )

      vnetBId: resourceId(
        subscription().subscriptionId,
        '${prefix}-rg-${regionList[j].key}',
        'Microsoft.Network/virtualNetworks',
        '${prefix}-vnet-${regionList[j].key}'
      )

      rgA: '${prefix}-rg-${regionList[i].key}'
      rgB: '${prefix}-rg-${regionList[j].key}'
    }
  ]
]

// Flatten nested arrays into a single array
var peeringsFlat = flatten(peeringPairs)

//
// DEPLOY PEERING MODULE
//
module peering 'modules/peering/peering.bicep' = {
  name: 'peer-all'
  dependsOn: [
    vnets
  ]
  params: {
    peerings: peeringsFlat
  }
}


//
// DOMAIN CONTROLLERS
//
module dc01 'modules/compute/vm-windows.bicep' = {
  name: 'dc01'
  scope: resourceGroup('${prefix}-rg-${dc01RegionKey}')
  dependsOn: [
    vnets
    peering
  ]
  params: {
    vmName: '${prefix}-dc01'
    vnetName: '${prefix}-vnet-${dc01RegionKey}'
    vmSize: vmSize
    adminUsername: adminUsername
    adminPassword: adminPassword
    tags: tags
   
    image: windowsServerImage     
    osDisk: osDisk                
  }
}

module dc02 'modules/compute/vm-windows.bicep' = {
  name: 'dc02'
  scope: resourceGroup('${prefix}-rg-${dc02RegionKey}')
  dependsOn: [
    vnets
    peering
  ]
  params: {
    vmName: '${prefix}-dc02'
    vnetName: '${prefix}-vnet-${dc02RegionKey}'
    vmSize: vmSize
    adminUsername: adminUsername
    adminPassword: adminPassword
    tags: tags
    
    image: windowsServerImage     
    osDisk: osDisk                
  }
}

module dc03 'modules/compute/vm-windows.bicep' = {
  name: 'dc03'
  scope: resourceGroup('${prefix}-rg-${dc03RegionKey}')
  dependsOn: [
    vnets
    peering
  ]
  params: {
    vmName: '${prefix}-dc03'
    vnetName: '${prefix}-vnet-${dc03RegionKey}'
    vmSize: vmSize
    adminUsername: adminUsername
    adminPassword: adminPassword
    tags: tags

    image: windowsServerImage     
    osDisk: osDisk                
  }
}

module dc04 'modules/compute/vm-windows.bicep' = {
  name: 'dc04'
  scope: resourceGroup('${prefix}-rg-${dc04RegionKey}')
  dependsOn: [
    vnets
    peering
  ]
  params: {
    vmName: '${prefix}-dc04'
    vnetName: '${prefix}-vnet-${dc04RegionKey}'
    vmSize: vmSize
    adminUsername: adminUsername
    adminPassword: adminPassword
    tags: tags

    image: windowsServerImage     
    osDisk: osDisk                
  }
}

module dc05 'modules/compute/vm-windows.bicep' = {
  name: 'dc05'
  scope: resourceGroup('${prefix}-rg-${dc05RegionKey}')
  dependsOn: [
    vnets
    peering
  ]
  params: {
    vmName: '${prefix}-dc05'
    vnetName: '${prefix}-vnet-${dc05RegionKey}'
    vmSize: vmSize
    adminUsername: adminUsername
    adminPassword: adminPassword
    tags: tags

    image: windowsServerImage     
    osDisk: osDisk                
  }
}

//
// CLIENT
//
module win01 'modules/compute/vm-windows.bicep' = {
  name: 'win01'
  scope: resourceGroup('${prefix}-rg-${windowsClient01RegionKey}')
  dependsOn: [
    vnets
    peering
  ]
  params: {
    vmName: '${prefix}-win01'
    vnetName: '${prefix}-vnet-${windowsClient01RegionKey}'
    vmSize: vmSize
    adminUsername: adminUsername
    adminPassword: adminPassword
    tags: tags

    image: windowsClientImage     
    osDisk: osDisk                
  }
}

module win02 'modules/compute/vm-windows.bicep' = {
  name: 'win02'
  scope: resourceGroup('${prefix}-rg-${windowsClient02RegionKey}')
  dependsOn: [
    vnets
    peering
  ]
  params: {
    vmName: '${prefix}-win02'
    vnetName: '${prefix}-vnet-${windowsClient02RegionKey}'
    vmSize: vmSize
    adminUsername: adminUsername
    adminPassword: adminPassword
    tags: tags

    image: windowsClientImage     
    osDisk: osDisk                
  }
}


//
// LINUX VM
//
module ubu01 'modules/compute/vm-linux.bicep' = {
  name: 'ubu01'
  scope: resourceGroup('${prefix}-rg-${ubuntu01RegionKey}')
  dependsOn: [
    vnets
    peering
  ]
  params: {
    vmName: '${prefix}-ubu01'
    vnetName: '${prefix}-vnet-${ubuntu01RegionKey}'
    vmSize: vmSize
    adminUsername: adminUsername
    tags: tags

    image: ubuntuImage               
    osDisk: osDisk                 
  }
}

module ubu02 'modules/compute/vm-linux.bicep' = {
  name: 'ubu02'
  scope: resourceGroup('${prefix}-rg-${ubuntu02RegionKey}')
  dependsOn: [
    vnets
    peering
  ]
  params: {
    vmName: '${prefix}-ubu02'
    vnetName: '${prefix}-vnet-${ubuntu02RegionKey}'
    vmSize: vmSize
    adminUsername: adminUsername
    tags: tags

    image: ubuntuImage               
    osDisk: osDisk                 
  }
}

module ubu03 'modules/compute/vm-linux.bicep' = {
  name: 'ubu03'
  scope: resourceGroup('${prefix}-rg-${ubuntu03RegionKey}')
  dependsOn: [
    vnets
    peering
  ]
  params: {
    vmName: '${prefix}-ubu03'
    vnetName: '${prefix}-vnet-${ubuntu03RegionKey}'
    vmSize: vmSize
    adminUsername: adminUsername
    tags: tags

    image: ubuntuImage               
    osDisk: osDisk                 
  }
}
