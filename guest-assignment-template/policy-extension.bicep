param vmName string
param location string = resourceGroup().location


resource myVM 'Microsoft.Compute/virtualMachines@2021-03-01' existing = {
  name: vmName
}

resource windowsVMGuestConfigExtension 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = {
  name: '${myVM.name}/AzurePolicyforWindows'
  location: location
  properties: {
    publisher: 'Microsoft.GuestConfiguration'
    type: 'ConfigurationforWindows'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
  }
}
