Configuration basic {
 
    Import-DSCResource -ModuleName 'PSDscResources'
 
    Node localhost {

          File AzSecPackDir {
               Ensure          = 'Present'
               Type            = 'Directory'
               DestinationPath = 'c:\Monitoring'

          }
     }
}

basic