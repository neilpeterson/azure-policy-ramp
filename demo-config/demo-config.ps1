Configuration basic {
 
    Import-DscResource -ModuleName PSDscResources
    Import-DscResource -ModuleName NewFile

    Node localhost {
         NewFile test {
              Path = "/tmp/test.txt"
              Content = "Replace"
              Ensure = "Present"
         }
    }
}

basic