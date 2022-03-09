<#
    .DESCRIPTION
        This example shows how to replace a line in a file with [nxFileContentReplace].

    .NOTES
        Because the resources are class based, you can also test the resource this way:

        using module nxtools # assuming it's available via $Env:PSModulePath.

        $rsrc = [nxFileContentReplace]@{
            Ensure = 'Absent'
            FilePath = '/etc/sudoers.d/90-cloud-init-users'
            EnsureExpectedPattern = '(?<user>[\w]+)\s(?<hosts>[^=]+)=(?<rule>[^\s]+)\sNOPASSWD:(?<target>.*)'
            Multiline = $false
            SearchPattern = '(?<user>[\w]+)\s(?<hosts>[^=]+)=(?<rule>[^\s]+)\sNOPASSWD:(?<target>.*)'
            SimpleMatch = $false
            ReplacementString = '${user} ${hosts}=${rule} ${target}'
            CaseSensitive = $false
        }

        $rsrc.Get().Reasons
        $rsrc.Set()
        $rsrc.Get()
#>

Configuration Example {
    Import-DscResource -ModuleName 'nxtools'

    nxFileContentReplace MyFile {
        Ensure = 'Absent'
        FilePath = '/etc/sudoers.d/90-cloud-init-users'
        EnsureExpectedPattern = '(?<user>[\w]+)\s(?<hosts>[^=]+)=(?<rule>[^\s]+)\sNOPASSWD:(?<target>.*)'
        Multiline = $false
        SearchPattern = '(?<user>[\w]+)\s(?<hosts>[^=]+)=(?<rule>[^\s]+)\sNOPASSWD:(?<target>.*)'
        SimpleMatch = $false
        ReplacementString = '${user} ${hosts}=${rule} ${target}'
        CaseSensitive = $false
    }

}
