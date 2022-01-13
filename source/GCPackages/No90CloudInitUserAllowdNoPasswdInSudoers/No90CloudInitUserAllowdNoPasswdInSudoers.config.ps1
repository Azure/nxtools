configuration No90CloudInitUserAllowdNoPasswdInSudoers {
    Import-DscResource -ModuleName nxtools

    node No90CloudInitUserAllowdNoPasswdInSudoers {
        nxFileContentReplace AzureUserInCloudInitSudoers {
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
}
