<#
    .DESCRIPTION
        This example shows how to Create a local group with [nxGroup].

    .NOTES
        Because the resources are class based, you can also test the resource this way:

        using module nxtools # assuming it's available via $Env:PSModulePath.

        $rsrc = [nxGroup]@{
            # the group must be present and have root as only member
            Ensure =  'Present'
            GroupName =  'foobar'
            Members = @('root')
        }

        $rsrc.Get().Reasons
        $rsrc.Set()
        $rsrc.Get()
#>

configuration CreateGroupFoobar {
    Import-DscResource -ModuleName 'nxtools'

    node localhost {
        nxGroup CreateGroupFoobar {
            # the group must be present and have root as only member
            Ensure =  'Present'
            GroupName =  'foobar'
            Members = @('root')
        }
    }
}
