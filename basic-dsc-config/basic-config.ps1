Configuration basic {

    Import-DscResource -ModuleName PsDesiredStateConfiguration

    node $AllNodes.NodeName {

        File AzSecPackDir {
            Ensure          = 'Present'
            Type            = 'Directory'
            DestinationPath = $Node.Directory
        }
    }
}