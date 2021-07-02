configuration InstalledApplicationLinux {
    Import-DscResource -ModuleName nxtools -ModuleVersion 0.3.0

    node InstalledApplicationLinux {
        GC_InstalledApplicationLinux InstalledApplicationLinux {
            # the group must be present but not contain root or test
            Name =  'installed_application_linux'
            AttributesYmlContent = 'packages: [Undefined Application]'
        }
    }
}
