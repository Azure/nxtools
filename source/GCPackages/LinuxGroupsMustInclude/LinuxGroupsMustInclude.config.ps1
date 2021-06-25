configuration LinuxGroupsMustInclude {
    Import-DscResource -ModuleName nxtools

        GC_LinuxGroup LinuxGroupsMustInclude {
            Ensure =  'Present'
            GroupName =  'foobar'
            PreferredGroupID = 1005
            MembersToIncludeAsString = 'root;gcolas'
        }
}
