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

//VM IPs for ping enable and testing connectivity between VMs in different regions, need to allow ICMP traffic for testing purposes.

var vmIps = {
  dc01: '10.4.0.5'
  dc02: '10.2.0.5'
  dc03: '10.1.0.5'
  dc04: '10.3.0.5'
  dc05: '10.0.0.4'
  win01: '10.4.0.4'
  win02: '10.2.0.4'
  ubu01: '10.1.0.4'
  ubu02: '10.3.0.4'
  ubu03: '10.0.0.5'
}


var vmIpArray = [
  vmIps.dc01
  vmIps.dc02
  vmIps.dc03
  vmIps.dc04
  vmIps.dc05
  vmIps.win01
  vmIps.win02
  vmIps.ubu01
  vmIps.ubu02
  vmIps.ubu03
]


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

//FROM AE TO ALL OTHER REGIONS

// ae → krc
module peering_ae_krc 'modules/peering/peering.bicep' = {
  name: 'peering-ae-krc'
  scope: resourceGroup('${prefix}-rg-ae')

  dependsOn: [
    vnets
  ]

  params: {
    vnetName: '${prefix}-vnet-ae'
    remoteVnetName: '${prefix}-vnet-krc'
    remoteVnetId: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${prefix}-rg-krc/providers/Microsoft.Network/virtualNetworks/${prefix}-vnet-krc'
  }
}

// ae → sdc
module peering_ae_sdc 'modules/peering/peering.bicep' = {
  name: 'peering-ae-sdc'
  scope: resourceGroup('${prefix}-rg-ae')

  dependsOn: [
    vnets
  ]

  params: {
    vnetName: '${prefix}-vnet-ae'
    remoteVnetName: '${prefix}-vnet-sdc'
    remoteVnetId: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${prefix}-rg-sdc/providers/Microsoft.Network/virtualNetworks/${prefix}-vnet-sdc'
  }
}

// ae → we
module peering_ae_we 'modules/peering/peering.bicep' = {
  name: 'peering-ae-we'
  scope: resourceGroup('${prefix}-rg-ae')

  dependsOn: [
    vnets
  ]

  params: {
    vnetName: '${prefix}-vnet-ae'
    remoteVnetName: '${prefix}-vnet-we'
    remoteVnetId: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${prefix}-rg-we/providers/Microsoft.Network/virtualNetworks/${prefix}-vnet-we'
  }
}

// ae → wus2
module peering_ae_wus2 'modules/peering/peering.bicep' = {
  name: 'peering-ae-wus2'
  scope: resourceGroup('${prefix}-rg-ae')

  dependsOn: [
    vnets
  ]

  params: {
    vnetName: '${prefix}-vnet-ae'
    remoteVnetName: '${prefix}-vnet-wus2'
    remoteVnetId: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${prefix}-rg-wus2/providers/Microsoft.Network/virtualNetworks/${prefix}-vnet-wus2'
  }
}

//FROM KRC TO ALL OTHER REGIONS

// krc → ae
module peering_krc_ae 'modules/peering/peering.bicep' = {
  name: 'peering-krc-ae'
  scope: resourceGroup('${prefix}-rg-krc')

  dependsOn: [
    vnets
  ]

  params: {
    vnetName: '${prefix}-vnet-krc'
    remoteVnetName: '${prefix}-vnet-ae'
    remoteVnetId: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${prefix}-rg-ae/providers/Microsoft.Network/virtualNetworks/${prefix}-vnet-ae'
  }
}

// krc → sdc
module peering_krc_sdc 'modules/peering/peering.bicep' = {
  name: 'peering-krc-sdc'
  scope: resourceGroup('${prefix}-rg-krc')

  dependsOn: [
    vnets
  ]

  params: {
    vnetName: '${prefix}-vnet-krc'
    remoteVnetName: '${prefix}-vnet-sdc'
    remoteVnetId: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${prefix}-rg-sdc/providers/Microsoft.Network/virtualNetworks/${prefix}-vnet-sdc'
  }
}

// krc → we
module peering_krc_we 'modules/peering/peering.bicep' = {
  name: 'peering-krc-we'
  scope: resourceGroup('${prefix}-rg-krc')

  dependsOn: [
    vnets
  ]

  params: {
    vnetName: '${prefix}-vnet-krc'
    remoteVnetName: '${prefix}-vnet-we'
    remoteVnetId: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${prefix}-rg-we/providers/Microsoft.Network/virtualNetworks/${prefix}-vnet-we'
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

//FROM SDC TO ALL OTHER REGIONS

// sdc → ae
module peering_sdc_ae 'modules/peering/peering.bicep' = {
  name: 'peering-sdc-ae'
  scope: resourceGroup('${prefix}-rg-sdc')

  dependsOn: [
    vnets
  ]

  params: {
    vnetName: '${prefix}-vnet-sdc'
    remoteVnetName: '${prefix}-vnet-ae'
    remoteVnetId: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${prefix}-rg-ae/providers/Microsoft.Network/virtualNetworks/${prefix}-vnet-ae'
  }
}

// sdc → krc
module peering_sdc_krc 'modules/peering/peering.bicep' = {
  name: 'peering-sdc-krc'
  scope: resourceGroup('${prefix}-rg-sdc')

  dependsOn: [
    vnets
  ]

  params: {
    vnetName: '${prefix}-vnet-sdc'
    remoteVnetName: '${prefix}-vnet-krc'
    remoteVnetId: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${prefix}-rg-krc/providers/Microsoft.Network/virtualNetworks/${prefix}-vnet-krc'
  }
}

// sdc → we
module peering_sdc_we 'modules/peering/peering.bicep' = {
  name: 'peering-sdc-we'
  scope: resourceGroup('${prefix}-rg-sdc')

  dependsOn: [
    vnets
  ]

  params: {
    vnetName: '${prefix}-vnet-sdc'
    remoteVnetName: '${prefix}-vnet-we'
    remoteVnetId: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${prefix}-rg-we/providers/Microsoft.Network/virtualNetworks/${prefix}-vnet-we'
  }
}

// sdc → wus2
module peering_sdc_wus2 'modules/peering/peering.bicep' = {
  name: 'peering-sdc-wus2'
  scope: resourceGroup('${prefix}-rg-sdc')

  dependsOn: [
    vnets
  ]

  params: {
    vnetName: '${prefix}-vnet-sdc'
    remoteVnetName: '${prefix}-vnet-wus2'
    remoteVnetId: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${prefix}-rg-wus2/providers/Microsoft.Network/virtualNetworks/${prefix}-vnet-wus2'
  }
}

//FROM WE TO ALL OTHER REGIONS

// we → ae
module peering_we_ae 'modules/peering/peering.bicep' = {
  name: 'peering-we-ae'
  scope: resourceGroup('${prefix}-rg-we')

  dependsOn: [
    vnets
  ]

  params: {
    vnetName: '${prefix}-vnet-we'
    remoteVnetName: '${prefix}-vnet-ae'
    remoteVnetId: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${prefix}-rg-ae/providers/Microsoft.Network/virtualNetworks/${prefix}-vnet-ae'
  }
}

// we → krc
module peering_we_krc 'modules/peering/peering.bicep' = {
  name: 'peering-we-krc'
  scope: resourceGroup('${prefix}-rg-we')

  dependsOn: [
    vnets
  ]

  params: {
    vnetName: '${prefix}-vnet-we'
    remoteVnetName: '${prefix}-vnet-krc'
    remoteVnetId: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${prefix}-rg-krc/providers/Microsoft.Network/virtualNetworks/${prefix}-vnet-krc'
  }
}

// we → sdc
module peering_we_sdc 'modules/peering/peering.bicep' = {
  name: 'peering-we-sdc'
  scope: resourceGroup('${prefix}-rg-we')

  dependsOn: [
    vnets
  ]

  params: {
    vnetName: '${prefix}-vnet-we'
    remoteVnetName: '${prefix}-vnet-sdc'
    remoteVnetId: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${prefix}-rg-sdc/providers/Microsoft.Network/virtualNetworks/${prefix}-vnet-sdc'
  }
}

// we → wus2
module peering_we_wus2 'modules/peering/peering.bicep' = {
  name: 'peering-we-wus2'
  scope: resourceGroup('${prefix}-rg-we')

  dependsOn: [
    vnets
  ]

  params: {
    vnetName: '${prefix}-vnet-we'
    remoteVnetName: '${prefix}-vnet-wus2'
    remoteVnetId: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${prefix}-rg-wus2/providers/Microsoft.Network/virtualNetworks/${prefix}-vnet-wus2'
  }
}

//FROM WUS2 TO ALL OTHER REGIONS

// wus2 → ae
module peering_wus2_ae 'modules/peering/peering.bicep' = {
  name: 'peering-wus2-ae'
  scope: resourceGroup('${prefix}-rg-wus2')

  dependsOn: [
    vnets
  ]

  params: {
    vnetName: '${prefix}-vnet-wus2'
    remoteVnetName: '${prefix}-vnet-ae'
    remoteVnetId: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${prefix}-rg-ae/providers/Microsoft.Network/virtualNetworks/${prefix}-vnet-ae'
  }
}

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

// wus2 → sdc
module peering_wus2_sdc 'modules/peering/peering.bicep' = {
  name: 'peering-wus2-sdc'
  scope: resourceGroup('${prefix}-rg-wus2')

  dependsOn: [
    vnets
  ]

  params: {
    vnetName: '${prefix}-vnet-wus2'
    remoteVnetName: '${prefix}-vnet-sdc'
    remoteVnetId: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${prefix}-rg-sdc/providers/Microsoft.Network/virtualNetworks/${prefix}-vnet-sdc'
  }
}

// wus2 → we
module peering_wus2_we 'modules/peering/peering.bicep' = {
  name: 'peering-wus2-we'
  scope: resourceGroup('${prefix}-rg-wus2')

  dependsOn: [
    vnets
  ]

  params: {
    vnetName: '${prefix}-vnet-wus2'
    remoteVnetName: '${prefix}-vnet-we'
    remoteVnetId: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${prefix}-rg-we/providers/Microsoft.Network/virtualNetworks/${prefix}-vnet-we'
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
    privateIp: vmIps.dc01
    testTargets: vmIpArray
    location: regions[dc01RegionKey]
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
    privateIp: vmIps.dc02
    testTargets: vmIpArray
    tags: tags
    location: regions[dc02RegionKey]
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
    privateIp: vmIps.dc03
    testTargets: vmIpArray
    location: regions[dc03RegionKey]
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
    privateIp: vmIps.dc04
    testTargets: vmIpArray
    location: regions[dc04RegionKey]
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
    privateIp: vmIps.dc05
    testTargets: vmIpArray
    location: regions[dc05RegionKey]
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
    privateIp: vmIps.win01
    testTargets: vmIpArray
    location: regions[windowsClient01RegionKey]
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
    privateIp: vmIps.win02
    testTargets: vmIpArray
    location: regions[windowsClient02RegionKey]
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
    privateIp: vmIps.ubu01
    testTargets: vmIpArray
    location: regions[ubuntu01RegionKey]
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
    privateIp: vmIps.ubu02
    testTargets: vmIpArray
    location: regions[ubuntu02RegionKey]
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
    privateIp: vmIps.ubu03
    testTargets: vmIpArray
    location: regions[ubuntu03RegionKey]
    tags: tags

    image: ubuntuImage               
    osDisk: osDisk                 
  }
}
