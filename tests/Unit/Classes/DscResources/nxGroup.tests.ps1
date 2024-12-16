using module nxtools

Describe "nxGroup resource for managing local groups and group members on a Linux node" {
    Context "When the group exists with one member" {
        BeforeAll {
            Mock -ModuleName "nxtools" -CommandName "Get-Content" -ParameterFilter {
                return $Path -eq "/etc/group"
            } -MockWith {
                return @(
                    "root:x:0:",
                    "users:x:100:"
                    "foobar:x:1001:root"
                )
            }
        }

        Context "When there is a members mismatch" {
            It ("Should be noncompliant") {
                $nxGroup = [nxGroup]::new()
                $nxGroup.Ensure = "Present"
                $nxGroup.GroupName = "foobar"
                $nxGroup.Members = @("root", "testuser")
                $result = $nxGroup.Get()
                $result.Reasons.Count | Should -Be 1
                $result.Reasons[0].Phrase | Should -Be "The members for Group 'foobar' do not match. It's missing 'testuser' and has the extra ''."
                $nxGroup.Test() | Should -Be $false
            }

            It ("Should update group members on remediation") {
                $nxGroup = [nxGroup]::new()
                $nxGroup.Ensure = "Present"
                $nxGroup.GroupName = "foobar"
                $nxGroup.Members = @("root", "testuser")

                Mock -ModuleName 'nxtools' -CommandName 'Invoke-NativeCommand' -ParameterFilter {
                    $expected = @("-M", "root,testuser", "foobar")
                    $diff = Compare-Object $Parameters $expected
                    return $Executable -eq "gpasswd" -and $diff.Count -eq 0
                } -Verifiable
                $nxGroup.Set() # Should not throw
                Should -InvokeVerifiable
            }
        }

        Context "When the desired value for members is no members" {
            It ("Should be noncompliant") {
                $nxGroup = [nxGroup]::new()
                $nxGroup.Ensure = "Present"
                $nxGroup.GroupName = "foobar"
                # PowerShell converts Members to null when it's an empty array in the configuration
                $nxGroup.Members = $null
                $result = $nxGroup.Get()
                # When Members is null, group members aren't checked
                $result.Reasons.Count | Should -Be 0
                $nxGroup.Test() | Should -Be $true
                $nxGroup.Force = $true
                $result = $nxGroup.Get()
                $result.Reasons.Count | Should -Be 1
                $result.Reasons[0].Phrase | Should -Be "The members for Group 'foobar' do not match. It's missing '' and has the extra 'root'."
                $nxGroup.Test() | Should -Be $false
            }

            It ("Should remove all group members on remediation") {
                $nxGroup = [nxGroup]::new()
                $nxGroup.Ensure = "Present"
                $nxGroup.GroupName = "foobar"
                $nxGroup.Members = $null
                $nxGroup.Force = $true

                Mock -ModuleName 'nxtools' -CommandName 'Invoke-NativeCommand' -ParameterFilter {
                    $expected = @("-d", "root", "foobar")
                    $diff = Compare-Object $Parameters $expected
                    return $Executable -eq "gpasswd" -and $diff.Count -eq 0
                } -Verifiable
                $nxGroup.Set() # Should not throw
                Should -InvokeVerifiable
            }
        }
    }
}
