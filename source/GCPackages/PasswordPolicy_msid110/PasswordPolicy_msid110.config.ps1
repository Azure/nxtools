configuration PasswordPolicy_msid110 {
    Import-DscResource -ModuleName nxtools -ModuleVersion 0.3.0

    node PasswordPolicy_msid110 {
        GC_msid110 PasswordPolicy_msid110 {
            Name =  'PasswordPolicy_msid110'
        }
    }
}
