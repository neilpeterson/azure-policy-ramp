param vmName string = 'guest-config-001'
param configName string = 'basic'
param packageLocation string = 'https://policyconfnepeters.blob.core.windows.net/guestconfig/basic-package.zip?sp=r&st=2022-06-22T04:29:38Z&se=2022-06-22T12:29:38Z&spr=https&sv=2021-06-08&sr=b&sig=pYOiHLm8lXK3z5AThQx2irt0cz2AX49afRTVJ3aDFLg%3D'
param packageHash string = '4B7AB4E7B951E994128751A4A3333B654ACD78360269F965C8E6A13226FBD9BC'
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
