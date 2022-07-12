Configuration tlssecure {

    Import-DscResource -ModuleName PSDscResources
    Import-DscResource -ModuleName SChannelDsc

    Node localhost {

        Protocol DisableTLS10 {
            Protocol            = "TLS 1.0"
            State               = "Disabled"
            IncludeClientSide   = $true
        }

        Protocol DisableTLS11 {
            Protocol            = "TLS 1.1"
            State               = "Disabled"
            IncludeClientSide   = $true
            
        }

        Protocol DisableSSL20 {
            Protocol            = "SSL 2.0"
            State               = "Disabled"
            IncludeClientSide   = $true
        }

        Protocol DisableSSL30 {
            Protocol            = "SSL 3.0"
            State               = "Disabled"
            IncludeClientSide   = $true
        }

        Protocol EnableTLS12 {
            Protocol            = "TLS 1.2"
            State               = "Enabled"
            IncludeClientSide   = $true
        }

        CipherSuites ConfigureCipherSuites {
            IsSingleInstance  = 'Yes'
            CipherSuitesOrder = @('TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384,TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256,TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256')
            Ensure            = "Present"
        }
    }
}

tls-secure