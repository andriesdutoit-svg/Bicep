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
  for region in items(regions): {
    name: '${prefix}-rg-${region.key}'
    location: region.value
    tags: tags
  }
]

//
// VNets
//
module vnets 'modules/networking/vnet.bicep' = [
  for (region, i) in items(regions): {
    name: 'vnet-${region.key}'
    scope: resourceGroup('${prefix}-rg-${region.key}')
    dependsOn: [
      rgs
    ]
    params: {
      vnetName: '${prefix}-vnet-${region.key}'
      location: region.value
      addressPrefix: '10.${i}.0.0/16'
      subnetPrefix: '10.${i}.0.0/24'
      dnsServers: []
      tags: tags
      externalAccessPrefixes: externalAccessPrefixes
    }
  }
]

//
// PEERING (explicit)
//

// wus2 → krc
module peering_wus2_krc 'modules/peering/peering.bicep' = {
  name: 'peering-wus2-krc'
  scope: resourceGroup('${prefix}-rg-wus2')

  dependsOn: [
    vnets
  ]

  params: {
    vnetName: '${prefix}-vnet-wus2'
    remoteVnetName: '${prefix}-vnet-krc'
    remoteVnetId: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${prefix}-rg-krc/providers/Microsoft.Network/virtualNetworks/${prefix}-vnet-krc'
  }
}

// krc → wus2
module peering_krc_wus2 'modules/peering/peering.bicep' = {
  name: 'peering-krc-wus2'
  scope: resourceGroup('${prefix}-rg-krc')

  dependsOn: [
    vnets
  ]

  params: {
    vnetName: '${prefix}-vnet-krc'
    remoteVnetName: '${prefix}-vnet-wus2'
    remoteVnetId: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${prefix}-rg-wus2/providers/Microsoft.Network/virtualNetworks/${prefix}-vnet-wus2'
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
  ]
  params: {
    vmName: '${prefix}-ubu01'
    vnetName: '${prefix}-vnet-${ubuntu01RegionKey}'
    vmSize: vmSize
    adminUsername: adminUsername
    adminPassword: adminPassword
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
  ]
  params: {
    vmName: '${prefix}-ubu02'
    vnetName: '${prefix}-vnet-${ubuntu02RegionKey}'
    vmSize: vmSize
    adminUsername: adminUsername
    adminPassword: adminPassword
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
  ]
  params: {
    vmName: '${prefix}-ubu03'
    vnetName: '${prefix}-vnet-${ubuntu03RegionKey}'
    vmSize: vmSize
    adminUsername: adminUsername
    adminPassword: adminPassword
    tags: tags

    image: ubuntuImage               
    osDisk: osDisk                 
  }
}
