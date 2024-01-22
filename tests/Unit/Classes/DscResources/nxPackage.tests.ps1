using module nxtools

$script:testPackage = "myTestPackage" # Mock package for testing

Describe "nxPackage resource for managing packages on a Linux node" {
    Context "When yum is used as the package manager" {
        BeforeAll {
            Mock -ModuleName 'nxtools' -CommandName 'Get-Command' -ParameterFilter { $Name -eq "yum" } -MockWith {
                @{
                    Name = "yum"
                }
            }
        }

        Context "When the package is not installed" {
            BeforeAll {
                Mock -ModuleName 'nxtools' -CommandName 'Invoke-NativeCommand' -ParameterFilter {
                    $expected = @('list', 'installed', $testPackage, '--quiet')
                    $diff = Compare-Object $Parameters $expected
                    return $Executable -eq "yum" -and $diff.Count -eq 0
                } -MockWith {
                    $exception = New-Object System.Exception("Error: No matching Packages to list")
                    return New-Object System.Management.Automation.ErrorRecord($exception, "errorId", "NotSpecified", $null)
                }
                Mock -ModuleName 'nxtools' -CommandName 'Invoke-NativeCommand' -ParameterFilter {
                    $expected = @('install', '-q', '-y', $testPackage)
                    $diff = Compare-Object $Parameters $expected
                    return $Executable -eq "yum" -and $diff.Count -eq 0
                } -MockWith {
                    ""
                }
            }

            It "Should be noncompliant with one Reason if we are expecting the package to be present" {
                $nxPackage = [nxPackage]::new()
                $nxPackage.Name = $testPackage
                $nxPackage.Ensure = "Present"
                $result = $nxPackage.Get()
                $result.Reasons.Count | Should -Be 1
                $result.Reasons[0].Code | Should -Be "nxPackage:nxPackage:Ensure"
                $result.Reasons[0].Phrase | Should -Be "The nxPackage is not in desired state because the package was expected Present but was Absent."
                $nxPackage.Test() | Should -Be $false
            }

            It "Should be compliant if we are expecting the package to be absent" {
                $nxPackage = [nxPackage]::new()
                $nxPackage.Name = $testPackage
                $nxPackage.Ensure = "Absent"
                $result = $nxPackage.Get()
                $result.Reasons.Count | Should -Be 0
                $nxPackage.Test() | Should -Be $true
            }

            It "Should install the package on remediation if we are expecting the package to be present" {
                $nxPackage = [nxPackage]::new()
                $nxPackage.Name = $testPackage
                $nxPackage.Ensure = "Present"
                $nxPackage.Set() # Should not throw
            }
        }
    }
}
