configuration LinuxGroupsMustExclude {
    Import-DscResource -ModuleName nxtools -ModuleVersion 0.3.0

    node LinuxGroupsMustExclude {
        GC_LinuxGroup LinuxGroupsMustExclude {
            # the group must be present but not contain root or test
            Ensure =  'Present'
            GroupName =  'foobar'
            MembersToExcludeAsString = 'root;test'
        }
    }
}
