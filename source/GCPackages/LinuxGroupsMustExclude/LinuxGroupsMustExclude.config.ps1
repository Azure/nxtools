configuration LinuxGroupsMustExclude {
    Import-DscResource -ModuleName nxtools -ModuleVersion 0.2.0

        nxGroup LinuxGroupsMustExclude {
            Ensure =  'Present'
            GroupName =  'foobar'
            PreferredGroupID = 1005
            MembersToExclude = 'root','gcolas'
        }
}
