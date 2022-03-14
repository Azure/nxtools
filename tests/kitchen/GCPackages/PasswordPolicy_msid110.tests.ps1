BeforeAll {
    $ProgressPreference = 'SilentlyContinue'
    $ErrorActionPreference = 'Continue'
    $ModulePath = (Join-Path -Path '/tmp/verifier' -ChildPath 'modules')
    $packageZipPath = Join-Path -Path $ModulePath -ChildPath 'GCPackages/PasswordPolicy_msid110*.zip'
    $packageZip = Get-Item -Path $packageZipPath -errorAction SilentlyContinue
}

Describe 'Password Policy msid1.10 GC Package (sshdPermitEmptyPasswords not enabled)' {
    it 'Package can be installed with GC Module' {

        Test-Path -Path $packageZip | Should -be $true -because (gci (split-path -parent $packageZipPath))
        { Import-Module -Name GuestConfiguration -ErrorAction Stop } | Should -not -Throw
        Test-Path -Path $packageZip | Should -be $true

        # Get-ChildItem -File $ModulePath | Should -not -BeNullOrEmpty -Because (Get-ChildItem $PWD.Path -Recurse)
    }

    it 'Sshd''s PermitEmptyPasswords is not disabled' {
        # #PermitEmptyPasswords no
        $result = $null
        $result = Get-GuestConfigurationPackageComplianceStatus -Path $packageZip
        $result.Resources.Reasons | Should -not -BeNullOrEmpty
    }
}
