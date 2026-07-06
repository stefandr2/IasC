Configuration WindowsFileServerRole {
    Import-DscResource -ModuleName PSDscResources

    Node localhost {
        WindowsFeature FileServerRole {
            Name   = "FS-FileServer"
            Ensure = "Present"
        }
    }
}
