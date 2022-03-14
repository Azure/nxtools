configuration LinuxGroupsMustInclude {
    Import-DscResource -ModuleName nxtools

    node LinuxGroupsMustInclude {
        GC_LinuxGroup LinuxGroupsMustInclude {
            Ensure =  'Present'
            GroupName =  'foobar'
            MembersToIncludeAsString = 'root;test'
        }
    }
}
