Configuration basic {
 
    Import-DscResource -ModuleName PSDscResources
 
    Node localhost {

          File AzSecPackDir {
               Ensure          = 'Present'
               Type            = 'Directory'
               DestinationPath = 'c:\Monitoring'

          }
     }
}

basic