param location string

param adminUsername string
@secure()
param adminPassword string

param vnetName string
param vnetAddressSpace string
param subnetName string
param subnetAddressSpace string

param dataDiskSize int
param allowedIPs array

module network 'modules/network.bicep' = {
  name: 'networkDeployment'
  params: {
    location: location
    vnetName: vnetName
    vnetAddressSpace: vnetAddressSpace
    subnetName: subnetName
    subnetAddressSpace: subnetAddressSpace
  }
}

module vm 'modules/vm.bicep' = {
  name: 'vmDeployment'
  params: {
    location: location
    adminUsername: adminUsername
    adminPassword: adminPassword
    subnetId: network.outputs.subnetId
    dataDiskSize: dataDiskSize
    allowedIPs: allowedIPs
  }
}
