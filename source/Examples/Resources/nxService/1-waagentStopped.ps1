<#
    .DESCRIPTION
        This example shows how to configure a service with [nxService].

    .NOTES
        Because the resources are class based, you can also test the resource this way:

        using module nxtools # assuming it's available via $Env:PSModulePath.

        $rsrc = [nxService]@{
            Name  = 'waagent.service'
            State = 'stopped'
            Enabled = $true
        }

        $rsrc.Get().Reasons
        $rsrc.Set()
        $rsrc.Get()
#>

configuration waagentStopped {
    Import-DscResource -ModuleName 'nxtools'

    node localhost {
        nxService CreateGroupFoobar {
            Name    = 'waagent.service'
            State   = 'stopped'
            Enabled = $true
        }
    }
}
