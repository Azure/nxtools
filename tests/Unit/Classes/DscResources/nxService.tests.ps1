using module nxtools

$script:testService = "myTestService.service" # Mock service for testing

Describe "nxService resource for managing services on a Linux node" {
    BeforeAll {
        Mock -ModuleName 'nxtools' -CommandName 'Invoke-NativeCommand' -ParameterFilter {
            $expected = @('is-enabled', $testService)
            $diff = Compare-Object $Parameters $expected
            return $Executable -eq "systemctl" -and $diff.Count -eq 0
        } -MockWith { "enabled" }

        Mock -ModuleName 'nxtools' -CommandName 'Get-nxInitSystem' -MockWith { [nxInitSystem]::systemd }
        Mock -ModuleName 'nxtools' -CommandName 'Get-Command' -ParameterFilter { $Name -eq "systemctl" } -MockWith { $true }
    }

    Context "When the service is running" {
        BeforeAll {
            Mock -ModuleName 'nxtools' -CommandName 'Invoke-NativeCommand' -ParameterFilter {
                $expected = @('list-units', '--type=service', '--no-legend', '--all', '--no-pager', $testService)
                $diff = Compare-Object $Parameters $expected
                return $Executable -eq "systemctl" -and $diff.Count -eq 0
            } -MockWith { "$testService loaded active running Regular background program processing daemon" }
        }

        It "Should be noncompliant with one Reason if we are expecting the service to be stopped" {
            $nxService = [nxService]::new()
            $nxService.Name = $testService
            $nxService.Enabled = $true
            $nxService.State = "Stopped"
            $result = $nxService.Get()
            $result.Reasons.Count | Should -Be 1
            $result.Reasons[0].Code | Should -Be "nxService:nxService:State"
            $result.Reasons[0].Phrase | Should -Be "The service '$testService' is present but we're expecting it to be 'Stopped' instead of 'Running'"
            $nxService.Test() | Should -Be $false
        }

        It "Should be compliant if we are expecting the service to be running" {
            $nxService = [nxService]::new()
            $nxService.Name = $testService
            $nxService.Enabled = $true
            $nxService.State = "Running"
            $result = $nxService.Get()
            $result.Reasons.Count | Should -Be 0
            $nxService.Test() | Should -Be $true
        }

        It "Should only return properties from the nxService class" {
            $nxService = [nxService]::new()
            $nxService.Name = $testService
            $nxService.Enabled = $true
            $nxService.State = "Running"
            $result = $nxService.Get()
            $expectedProperties = [nxService]::new().PSObject.Properties
            $result.PSObject.Properties | ForEach-Object {
                $_.Name | Should -BeIn $expectedProperties.Name
            }
            $expectedProperties.PSObject.Properties | ForEach-Object {
                $_.Name | Should -BeIn $result.Name
            }
        }
    }

    Context "When the service is stopped" {
        BeforeAll {
            Mock -ModuleName 'nxtools' -CommandName 'Invoke-NativeCommand' -ParameterFilter {
                $expected = @('list-units', '--type=service', '--no-legend', '--all', '--no-pager', $testService)
                $diff = Compare-Object $Parameters $expected
                return $Executable -eq "systemctl" -and $diff.Count -eq 0
            } -MockWith { "$testService loaded inactive dead Regular background program processing daemon" }
        }

        It "Should be compliant if we are expecting the service to be stopped" {
            $nxService = [nxService]::new()
            $nxService.Name = $testService
            $nxService.Enabled = $true
            $nxService.State = "Stopped"
            $result = $nxService.Get()
            $result.Reasons.Count | Should -Be 0
            $nxService.Test() | Should -Be $true
        }

        It "Should be noncompliant with one Reason if we are expecting the service to be running" {
            $nxService = [nxService]::new()
            $nxService.Name = $testService
            $nxService.Enabled = $true
            $nxService.State = "Running"
            $result = $nxService.Get()
            $result.Reasons.Count | Should -Be 1
            $result.Reasons[0].Code | Should -Be "nxService:nxService:State"
            $result.Reasons[0].Phrase | Should -Be "The service '$testService' is present but we're expecting it to be 'Running' instead of 'Stopped'"
            $nxService.Test() | Should -Be $false
        }
    }

    Context "When the service does not exist" {
        BeforeAll {
            Mock -ModuleName 'nxtools' -CommandName 'Invoke-NativeCommand' -ParameterFilter {
                $expected = @('is-enabled', "")
                $diff = Compare-Object $Parameters $expected
                return $Executable -eq "systemctl" -and $diff.Count -eq 0
            } -MockWith { "enabled" }

            Mock -ModuleName 'nxtools' -CommandName 'Invoke-NativeCommand' -ParameterFilter {
                $expected = @('list-units', '--type=service', '--no-legend', '--all', '--no-pager', $testService)
                $diff = Compare-Object $Parameters $expected
                return $Executable -eq "systemctl" -and $diff.Count -eq 0
            } -MockWith { "" }
        }

        It "Should be always be compliant" {
            $nxService = [nxService]::new()
            $nxService.Name = $testService
            $nxService.Enabled = $false
            $nxService.State = "Stopped"
            $result = $nxService.Get()
            $result.Reasons.Count | Should -Be 0
            $nxService.Test() | Should -Be $true
            $nxService.Enabled = $true
            $nxService.State = "Running"
            $result = $nxService.Get()
            $result.Reasons.Count | Should -Be 0
            $nxService.Test() | Should -Be $true
        }
    }
}
