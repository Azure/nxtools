BeforeAll {
    $ProgressPreference = 'SilentlyContinue'
    $ErrorActionPreference = 'Continue'
    $ModulePath = (Join-Path -Path '/tmp/verifier' -ChildPath 'modules')
    $packageZipPath = Join-Path -Path $ModulePath -ChildPath 'GCPackages/PasswordPolicy_msid232*.zip'
    $packageZip = Get-Item -Path $packageZipPath -errorAction SilentlyContinue
}

Describe 'Password Policy msid23.2 GC Package (no accounts without passwords)' {
    it 'Package can be installed with GC Module' {

        Test-Path -Path $packageZip | Should -be $true -because (gci (split-path -parent $packageZipPath))
        { Import-Module -Name GuestConfiguration -ErrorAction Stop } | Should -not -Throw
        Test-Path -Path $packageZip | Should -be $true

    }

    it 'No Account found without password' {
        if (
            $userAccountWithoutPassword = Get-nxLocalUser | Where-Object -FilterScript {
                [string]::IsNullOrEmpty($_.etcShadow.Encryptedpassword)
            }
        )
        {
            $userAccountWithoutPassword | Remove-nxLocalUser -Force -Confirm:$false
        }

        $result = $null
        $result = Get-GuestConfigurationPackageComplianceStatus -Path $packageZip
        $result.Resources.Reasons | Should -BeNullOrEmpty
    }

    it 'Account caught with an empty password' {
        if (-not (Get-nxLocalUser -UserName test2))
        {
            New-nxLocalUser -UserName test2 -EncryptedPassword ''
        }

        $null = passwd -d test2 *>&1
        $result = $null
        $result = Get-GuestConfigurationPackageComplianceStatus -Path $packageZip
        $result.Resources.Reasons | Should -not -BeNullOrEmpty
    }
}
