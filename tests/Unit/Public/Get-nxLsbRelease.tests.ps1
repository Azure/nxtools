Describe 'Get-LsbRelease function' {
    Context "When the lsb-release package is installed" {
        BeforeAll {
            Mock -ModuleName 'nxtools' -CommandName 'Invoke-NativeCommand' -ParameterFilter {
                return $Executable -eq "lsb_release"
            } -MockWith {
                return @(
                    "No LSB modules are available.",
                    "Distributor ID: Ubuntu",
                    "Description:    Ubuntu 20.04.6 LTS",
                    "Release:        20.04",
                    "Codename:       focal"
                )
            }
        }

        It 'Should return information about the machine' {
            $result = Get-nxLsbRelease
            $result.DistributorID | Should -Be 'Ubuntu'
            $result.Description | Should -Be 'Ubuntu 20.04.6 LTS'
            $result.Release | Should -Be '20.04'
            $result.Codename | Should -Be 'focal'
        }
    }
}
