<#
    .DESCRIPTION
        This example shows how to make sure a file exists

    .NOTES
        Because the resources are class based, you can also test the resource this way:

        using module nxtools # assuming it's available via $Env:PSModulePath.

        $rsrc = [nxFile]@{
            Ensure = 'Present'
            DestinationPath = '/tmp/myfile'
            # SourcePath = '/tmp/myFileToCopyFrom'
            Type = 'File'
            # Contents = 'Some content I want to manage here.'
            Mode = '0777'
            # Force = $true
            Owner = 'root'
            Group = 'root'
        }

        $rsrc.Get().Reasons
        $rsrc.Set()
        $rsrc.Get()
#>

Configuration Example {
    Import-DscResource -ModuleName 'nxtools'

    nxFile MyFile {
        Ensure = 'Present'
        DestinationPath = '/tmp/myfile'
        # SourcePath = '/tmp/myFileToCopyFrom'
        Type = 'File'
        # Contents = 'Some content I want to manage here.'
        Mode = '0777'
        # Force = $true
        Owner = 'root'
        Group = 'root'
    }

}
