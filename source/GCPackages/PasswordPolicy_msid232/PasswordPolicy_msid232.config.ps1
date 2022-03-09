configuration PasswordPolicy_msid232 {
    Import-DscResource -ModuleName nxtools

    node PasswordPolicy_msid232 {
        GC_msid232 PasswordPolicy_msid232 {
            Name =  'PasswordPolicy_msid232'
        }
    }
}
