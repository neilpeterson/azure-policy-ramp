Configuration azsecpack {
    Import-DscResource -ModuleName PSDscResources
    Import-DscResource -ModuleName AzSecPackFile

    $Role = $ConfigurationData.NonNodeData.AzSecPackRole
    $Account = $ConfigurationData.NonNodeData.AzSecPackAcct
    $NameSpace = $ConfigurationData.NonNodeData.AzSecPackNS
    $CertThumb = $ConfigurationData.NonNodeData.AzSecPackCert

    $AzSecPackCMD = "
    set MONITORING_DATA_DIRECTORY=C:\Monitoring\Data
    set MONITORING_TENANT=%USERNAME%
    set MONITORING_ROLE=admin
    set MONITORING_ROLE_INSTANCE=%COMPUTERNAME%
    set MONITORING_GCS_ENVIRONMENT=DiagnosticsProd
    set MONITORING_GCS_ACCOUNT=shivam
    set MONITORING_GCS_NAMESPACE=policy
    set MONITORING_GCS_REGION=centralus
    set MONITORING_GCS_AUTH_ID_TYPE=AuthKeyVault
    set MONITORING_GCS_AUTH_ID= PPE.GENEVA.KEYVAULT.AZSECPACK.FIT-MTP.FME.MICROSOFT.COM
    set MONITORING_CONFIG_VERSION=1.0
    set AZSECPACK_PILOT_FEATURES=MdeServer2019Support
    %MonAgentClientLocation%\MonAgentClient.exe -useenv"

    Node localhost {

        AzSecPackFile AzSecPack {
            path = 'C:\Monitoring\runagentClient.cmd'
            ensure = 'Present'
        }


        # NewFile AzSecPackDir {
        #     Path = 'C:\Monitoring'
        #     Ensure = 'Present'
        # }

        # Newfile AzSecPackCMD {
        #     Ensure = 'Present'
        #     DependsOn = '[NewFile] AzSecPackDir'
        #     Path = "C:\Monitoring\runagentClient.cmd"
        #     Content = $AzSecPackCMD
        # }

        # ScheduledTask AzSecPack {
        #     TaskName            = 'Geneva'
        #     ScheduleType        = 'AtStartup'
        #     ActionExecutable    = 'C:\Monitoring\runagentClient.cmd'
        #     BuiltInAccount      = 'System'
        # }

        # Script AzSecPackStart {
        #     SetScript = {
        #         Start-ScheduledTask Geneva
        #     }
        #     TestScript = { 
        #         Test-Path C:\Monitoring\Data\
        #     }
        #     GetScript = { @{} }
        #     DependsOn = '[ScheduledTask]AzSecPack'
        # }

    }
}

azsecpack