using module nxtools

Describe "nxScript resource for executing scripts in PowerShell 7" {
    Context "When GetScript is not defined" {
        It "Should return the nxScript object with a default Reason" {
            $nxScript = [nxScript]::new()
            $result = $nxScript.Get()
            $result | Should -Be $nxScript
            $result.Reasons.Count | should -Be 1
            $result.Reasons[0].Code | Should -Be "Script:Script:GetScriptNotDefined"
            $result.Reasons[0].Phrase | Should -Be "The GetScript script block was not defined"
        }
    }

    Context "When GetScript is defined" {
        It "Should invoke the GetScript script block" {
            $nxScript = [nxScript]::new()
            $nxScript.GetScript = {
                $Reason = [Reason]::new()
                $Reason.Code = "Script:Script:Reason"
                $Reason.Phrase = "Reason"
                return @{
                    Reasons = @($Reason)
                }
            }

            $result = $nxScript.Get()
            $result.Reasons.Count | Should -Be 1
            $result.Reasons[0].Code | Should -Be "Script:Script:Reason"
            $result.Reasons[0].Phrase | Should -Be "Reason"
        }

        It "Should throw an error if GetScript returns an error" {
            $nxScript = [nxScript]::new()
            $nxScript.GetScript = { throw "Error" }
            { $nxScript.Get() } | Should -Throw "The GetScript script block returned an error: Error."
        }

        It "Should throw an error if GetScript does not return a hashtable" {
            $nxScript = [nxScript]::new()
            $nxScript.GetScript = { return "not a hashtable" }
            { $nxScript.Get() } | Should -Throw "The GetScript script block must return a hashtable that contains a non-empty list of Reason objects under the Reasons key."
        }

        It "Should throw an error if GetScript does not return a Reasons key" {
            $nxScript = [nxScript]::new()
            $nxScript.GetScript = {
                return @{
                    NotReasons = @()
                }
            }

            { $nxScript.Get() } | Should -Throw "The GetScript script block must return a hashtable that contains a non-empty list of Reason objects under the Reasons key."
        }

        It "Should throw an error if GetScript returns an empty Reasons list" {
            $nxScript = [nxScript]::new()
            $nxScript.GetScript = {
                return @{
                    Reasons = @()
                }
            }

            { $nxScript.Get() } | Should -Throw "The GetScript script block must return a hashtable that contains a non-empty list of Reason objects under the Reasons key."
        }

        It "Should throw an error if GetScript returns a non-Reason object in the Reasons list" {
            $nxScript = [nxScript]::new()
            $nxScript.GetScript = {
                return @{
                    Reasons = @(1)
                }
            }

            { $nxScript.Get() } | Should -Throw "The GetScript script block must return a hashtable that contains a non-empty list of Reason objects under the Reasons key."
        }
    }

    Context "wWhen TestScript is defined" {
        It "Should invoke the TestScript script block" {
            $nxScript = [nxScript]::new()
            $nxScript.TestScript = { return $true }
            $nxScript.Test() | Should -Be $true
        }

        It "Should throw an error if TestScript returns an error" {
            $nxScript = [nxScript]::new()
            $nxScript.TestScript = { throw "Error" }
            { $nxScript.Test() } | Should -Throw "The TestScript script block returned an error: Error."
        }

        It "Should throw an error if TestScript does not return a Boolean" {
            $nxScript = [nxScript]::new()
            $nxScript.TestScript = { return "not a boolean" }
            { $nxScript.Test() } | Should -Throw "The TestScript script block must return a Boolean."
        }
    }

    Context "When SetScript is not defined" {
        It "Should not throw an error" {
            $nxScript = [nxScript]::new()
            { $nxScript.Set() } | Should -Not -Throw
        }
    }

    Context "When SetScript is defined" {
        It "Should invoke the SetScript script block" {
            $nxScript = [nxScript]::new()
            $nxScript.SetScript = { return $null }
            { $nxScript.Set() } | Should -Not -Throw
        }
    }
}
