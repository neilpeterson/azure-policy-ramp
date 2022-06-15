# Azure Policy Ramp Notes

## PowerShell environment and Modules.

Make sure that you are working with PowerShell 7.

```
$> $PSVersionTable

Name                           Value
----                           -----
PSVersion                      7.2.3
PSEdition                      Core
GitCommitId                    7.2.3
OS                             Microsoft Windows 10.0.22000
Platform                       Win32NT
PSCompatibleVersions           {1.0, 2.0, 3.0, 4.0…}
PSRemotingProtocolVersion      2.3
SerializationVersion           1.1.0.1
WSManStackVersion              3.0
```

Install the following PowerShell modules.

```
find-module PSDesiredStateConfiguration | install-module
find-module PSDSCResources | install-module
find-module GuestConfiguration | install-module
```

## Compile MOF file

```powershell
.\basic-dsc-config-localhost\basic-localhost.ps1
```

## Create a custom Azure Policy / DSC3 config package.

```powershell
New-GuestConfigurationPackage -Name 'basic' -Configuration './basic/localhost.mof' -Type Audit -Force
```

## Test configuration package

```powershell
Get-GuestConfigurationPackageComplianceStatus -Path ./basic/basic.zip
```