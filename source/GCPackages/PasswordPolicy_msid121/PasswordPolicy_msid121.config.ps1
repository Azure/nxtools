configuration PasswordPolicy_msid121 {
    Import-DscResource -ModuleName nxtools #-ModuleVersion 0.3.0

    node PasswordPolicy_msid121 {
        GC_msid121 PasswordPolicy_msid121 {
            Name =  'PasswordPolicy_msid121'
        }
    }
}
