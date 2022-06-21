# Populate with demo config code

# Create c:\monitoring
# Create c:\Monitoring\runagentClient.cmd
# Create scheduled task for AzSecPack

Configuration basic {
 
    Import-DscResource -ModuleName PSDscResources
    Import-DscResource -ModuleName NewFile

    Node localhost {
         NewFile test {
              Path = "/tmp/test.txt"
              Content = "DSC Rocks!"
              Ensure = "Present"
         }
    }
}

basic