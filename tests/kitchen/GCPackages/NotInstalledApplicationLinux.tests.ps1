BeforeAll {
    $ProgressPreference = 'SilentlyContinue'
    $ErrorActionPreference = 'Continue'
    $ModulePath = (Join-Path -Path '/tmp/verifier' -ChildPath 'modules')
    $packageZipPath = Join-Path -Path $ModulePath -ChildPath 'GCPackages/NotInstalledApplicationLinux*.zip'
    $packageZip = Get-Item -Path $packageZipPath -errorAction SilentlyContinue
}
Describe 'Test NotInstalledApplicationLinux Audit Package' {
    it 'Package should be available' {

        Test-Path -Path $packageZip | Should -be $true -because (gci (split-path -parent $packageZipPath))
        { Import-Module -Name GuestConfiguration -ErrorAction Stop } | Should -not -Throw
        { Install-GuestConfigurationAgent -ErrorAction Stop -Force } | Should -not -Throw
        { Install-GuestConfigurationPackage -Force -Path $packageZip } | Should -not -Throw
    }

    it 'Gets the NotInstalledApplicationLinux ''somethingNotInstalled'' Package Compliance Status (with params)' {

        $result = $null
        $result = Get-GuestConfigurationPackageComplianceStatus -Path $packageZip -Parameter @{
            ResourceType = "GC_NotInstalledApplicationLinux"
            ResourceId = "NotInstalledApplicationLinux"
            ResourcePropertyName =  "AttributesYmlContent"
            ResourcePropertyValue = "packages: [somethingNotInstalled]"
        }

        $result.Resources.Reasons | Should -BeNullOrEmpty
        $result.complianceStatus | Should -be $true
    }

    it 'Gets the non-compliant NotInstalledApplicationLinux @(''powershell'',''somethingNotInstalled'') Package Compliance Status (with params)' {

        $result = $null
        $result = Get-GuestConfigurationPackageComplianceStatus -Path $packageZip -Parameter @{
            ResourceType = "GC_NotInstalledApplicationLinux"
            ResourceId = "NotInstalledApplicationLinux"
            ResourcePropertyName =  "AttributesYmlContent"
            ResourcePropertyValue = "powershell;somethingNotInstalled"
        }

        $result.Resources.Reasons | Should -not -BeNullOrEmpty
        $result.complianceStatus | Should -be $false
    }
}
