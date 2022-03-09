configuration NotInstalledApplicationLinux {
    Import-DscResource -ModuleName nxtools

    node NotInstalledApplicationLinux {
        GC_NotInstalledApplicationLinux NotInstalledApplicationLinux {
            # the group must be present but not contain root or test
            Name =  'installed_application_linux'
            AttributesYmlContent = 'packages: [Undefined Application]'
        }
    }
}
