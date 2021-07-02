configuration PasswordPolicy_msid232 {
    Import-DscResource -ModuleName nxtools #-ModuleVersion 0.3.0

    node PasswordPolicy_msid232 {
        GC_msid232 PasswordPolicy_msid232 {
            Name =  'PasswordPolicy_msid232'
        }
    }
}
