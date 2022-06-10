# Azure Policy Ramp Notes

Compile MOF file.

```powershell
.\basic-dsc-config-localhost\basic-localhost.ps1
```

Create a custom Azure Policy / DSC3 config package.

When trying to run the `New-GuestConfigurationPackage` command, I was receiving the following error.

```
Exception: 'PsDesiredStateConfiguration' module is not supported by GuestConfiguration. Please use 'PSDSCResources' module instead of 'PsDesiredStateConfiguration' module in DSC configuration.
```

To remediate, I've removed this line from the MOF file.

```
 ModuleName = "PSDesiredStateConfiguration";
```

Now when running the following command, the .zip file is created; however unsure at this point if it will work.

```powershell
New-GuestConfigurationPackage -Name 'basic' -Configuration './basic/localhost.mof' -Type Audit -Force
```

