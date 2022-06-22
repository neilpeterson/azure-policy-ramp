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