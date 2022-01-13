<#
    .DESCRIPTION
        This example shows how to Append a line to an existing file with [nxFileLine].
        The nxFileLine is meant to replace the DSC for Linux resouce.
        Use the nxFileContentReplace for more advanced scenarios.

    .NOTES
        Because the resources are class based, you can also test the resource this way:

        using module nxtools # assuming it's available via $Env:PSModulePath.

        $rsrc = [nxFileLine]@{
            FilePath = "/etc/sudoers"
            ContainsLine = 'Defaults:monuser !requiretty'
            DoesNotContainPattern = "Defaults:monuser[ ]+requiretty"
        }

        $rsrc.Get().Reasons
        $rsrc.Set()
        $rsrc.Get()
#>

Configuration Example {
    Import-DscResource -ModuleName 'nxtools'

    nxFileLine DoNotRequireTTY
    {
        FilePath = "/etc/sudoers"
        ContainsLine = 'Defaults:monuser !requiretty'
        DoesNotContainPattern = "Defaults:monuser[ ]+requiretty"
    }

}
