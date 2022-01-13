configuration PasswordPolicy_msid110 {
    Import-DscResource -ModuleName nxtools

    node PasswordPolicy_msid110 {
        GC_msid110 PasswordPolicy_msid110 {
            Name =  'PasswordPolicy_msid110'
        }
    }
}
