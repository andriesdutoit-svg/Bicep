param adminUsername string
@secure()
param adminPassword string

param locations object = {
  wus2: 'westus2'
  krs:  'koreasouth'
  sdc:  'swedencentral'
}

param vmSize string = 'Standard_B2s'

targetScope = 'subscription'

// ✅ Resource Groups
resource rgWus2 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'lab1-rg-wus2'
  location: locations.wus2
}

resource rgKrs 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'lab1-rg-krs'
  location: locations.krs
}

resource rgSdc 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'lab1-rg-sdc'
  location: locations.sdc
}

// ✅ VNets per region
module netWus2 './networking.bicep' = {
  name: 'net-wus2'
  scope: rgWus2
  params: {
    vnetName: 'lab1-vnet-wus2'
    addressPrefix: '10.0.0.0/16'
    subnetPrefix: '10.0.0.0/24'
  }
}

module netKrs './networking.bicep' = {
  name: 'net-krs'
  scope: rgKrs
  params: {
    vnetName: 'lab1-vnet-krs'
    addressPrefix: '10.1.0.0/16'
    subnetPrefix: '10.1.0.0/24'
  }
}

module netSdc './networking.bicep' = {
  name: 'net-sdc'
  scope: rgSdc
  params: {
    vnetName: 'lab1-vnet-sdc'
    addressPrefix: '10.2.0.0/16'
    subnetPrefix: '10.2.0.0/24'
  }
}

// ✅ Peering
module peer './peering.bicep' = {
  name: 'peer-all'
  dependsOn: [
    netWus2
    netKrs
    netSdc
  ]
}

// ✅ DCs
module dc01 './vm-windows.bicep' = {
  name: 'dc01'
  scope: rgWus2
  params: {
    vmName: 'dc01'
    vnetName: 'lab1-vnet-wus2'
    privateIp: '10.0.0.4'
    vmSize: vmSize
    adminUsername: adminUsername
    adminPassword: adminPassword
  }
}

module dc02 './vm-windows.bicep' = {
  name: 'dc02'
  scope: rgSdc
  params: {
    vmName: 'dc02'
    vnetName: 'lab1-vnet-sdc'
    privateIp: '10.2.0.4'
    vmSize: vmSize
    adminUsername: adminUsername
    adminPassword: adminPassword
  }
}

module dc03 './vm-windows.bicep' = {
  name: 'dc03'
  scope: rgKrs
  params: {
    vmName: 'dc03'
    vnetName: 'lab1-vnet-krs'
    privateIp: '10.1.0.4'
    vmSize: vmSize
    adminUsername: adminUsername
    adminPassword: adminPassword
  }
}

// ✅ Client
module client './vm-windows.bicep' = {
  name: 'client'
  scope: rgSdc
  params: {
    vmName: 'client01'
    vnetName: 'lab1-vnet-sdc'
    privateIp: '10.2.0.10'
    vmSize: vmSize
    adminUsername: adminUsername
    adminPassword: adminPassword
  }
}

// ✅ Linux
module linux './vm-linux.bicep' = {
  name: 'linux'
  scope: rgKrs
  params: {
    vmName: 'linux01'
    vnetName: 'lab1-vnet-krs'
    privateIp: '10.1.0.10'
    vmSize: vmSize
    adminUsername: adminUsername
  }
}
