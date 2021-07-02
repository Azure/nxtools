BeforeAll {
    $ProgressPreference = 'SilentlyContinue'
    $ErrorActionPreference = 'Continue'
    $ModulePath = (Join-Path -Path '/tmp/verifier' -ChildPath 'modules')
    $packageZipPath = Join-Path -Path $ModulePath -ChildPath 'GCPolicyPackages/InstalledApplicationLinux*.zip'
    $packageZip = Get-Item -Path $packageZipPath -errorAction SilentlyContinue
}
Describe 'Test InstalledApplicationLinux Audit Package' {
    it 'Package should be available' {

        Test-Path -Path $packageZip | Should -be $true -because (gci (split-path -parent $packageZipPath))
        { Import-Module -Name GuestConfiguration -ErrorAction Stop } | Should -not -Throw
        { Install-GuestConfigurationAgent -ErrorAction Stop -Force } | Should -not -Throw
        { Install-GuestConfigurationPackage -Force -Path $packageZip } | Should -not -Throw
    }

    it 'Gets the InstalledApplicationLinux ''powershell-preview'' Package Compliance Status (with params)' {

        $result = $null
        $result = Get-GuestConfigurationPackageComplianceStatus -Package $packageZip -Parameter @{
            ResourceType = "GC_InstalledApplicationLinux"
            ResourceId = "InstalledApplicationLinux"
            ResourcePropertyName =  "AttributesYmlContent"
            ResourcePropertyValue = "packages: [powershell-preview]"
        }

        $result.Resources.Reasons | Should -BeNullOrEmpty
        $result.complianceStatus | Should -be $true
    }

    it 'Gets the non-compliant InstalledApplicationLinux @(''powershell-preview'',''somethingNotInstalled'') Package Compliance Status (with params)' {

        $result = $null
        $result = Get-GuestConfigurationPackageComplianceStatus -Package $packageZip -Parameter @{
            ResourceType = "GC_InstalledApplicationLinux"
            ResourceId = "InstalledApplicationLinux"
            ResourcePropertyName =  "AttributesYmlContent"
            ResourcePropertyValue = "powershell-preview;somethingNotInstalled"
        }

        $result.Resources.Reasons | Should -not -BeNullOrEmpty
        $result.complianceStatus | Should -be $false
    }
}
