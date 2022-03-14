configuration PasswordPolicy_msid121 {
    Import-DscResource -ModuleName nxtools

    node PasswordPolicy_msid121 {
        GC_msid121 PasswordPolicy_msid121 {
            Name =  'PasswordPolicy_msid121'
        }
    }
}
