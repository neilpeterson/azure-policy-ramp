Configuration tls {

    Import-DscResource -ModuleName PSDscResources
    Import-DscResource -ModuleName SChannelDsc

    Node localhost {

        Protocol DisableTLS10 {
            Protocol = "TLS 1.0"
            State    = "Disabled"
            IncludeClientSide = $true
        }

        Protocol DisableTLS11 {
            Protocol = "TLS 1.1"
            State    = "Disabled"
            IncludeClientSide = $true
            
        }

    }

}

tls