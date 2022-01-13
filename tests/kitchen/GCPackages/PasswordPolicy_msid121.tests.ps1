BeforeAll {
    $ProgressPreference = 'SilentlyContinue'
    $ErrorActionPreference = 'Continue'
    $ModulePath = (Join-Path -Path '/tmp/verifier' -ChildPath 'modules')
    $packageZipPath = Join-Path -Path $ModulePath -ChildPath 'GCPackages/PasswordPolicy_msid121*.zip'
    $packageZip = Get-Item -Path $packageZipPath -errorAction SilentlyContinue
}

Describe 'Password Policy msid12.1 GC Package (no accounts without passwords)' {
    it 'Package can be installed with GC Module' {

        Test-Path -Path $packageZip | Should -be $true -because (gci (split-path -parent $packageZipPath))
        { Import-Module -Name GuestConfiguration -ErrorAction Stop } | Should -not -Throw
        { Install-GuestConfigurationAgent -ErrorAction Stop -Force } | Should -not -Throw
        { Install-GuestConfigurationPackage -Force -Path $packageZip } | Should -not -Throw

    }

    it '/etc/passwd to have mode 0664' {
        if (
            (Get-nxitem /etc/passwd).Mode.ToOCtal() -ne '0644'
        )
        {
            Set-nxMode -Path /etc/passwd -Mode 0644 -Confirm:$false -Force
        }

        $result = $null
        $result = Get-GuestConfigurationPackageComplianceStatus -Path $packageZip
        $result.Resources.Reasons | Should -BeNullOrEmpty
    }

    it 'Account caught with an empty password' {
        if (
            (Get-nxitem /etc/passwd).Mode.ToOCtal() -eq '0644'
        )
        {
            Set-nxMode -Path /etc/passwd -Mode 0777 -Confirm:$false -Force
        }

        $result = $null
        $result = Get-GuestConfigurationPackageComplianceStatus -Path $packageZip
        $result.Resources.Reasons | Should -not -BeNullOrEmpty
    }
}
