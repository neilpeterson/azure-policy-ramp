param vmName string
param configName string
param packageLocation string
param packageHash string
param location string = resourceGroup().location

resource myVM 'Microsoft.Compute/virtualMachines@2021-03-01' existing = {
  name: vmName
}

resource myConfiguration 'Microsoft.GuestConfiguration/guestConfigurationAssignments@2020-06-25' = {
  name: configName
  scope: myVM
  location: location
  properties: {
    guestConfiguration: {
      name: configName
      contentUri: packageLocation
      contentHash:packageHash
      version: '1.0'
      assignmentType: 'ApplyAndMonitor'
    }
  }
}
