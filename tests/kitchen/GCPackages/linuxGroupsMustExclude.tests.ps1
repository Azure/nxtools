BeforeAll {
    $ProgressPreference = 'SilentlyContinue'
    $ErrorActionPreference = 'Continue'
    $ModulePath = (Join-Path -Path '/tmp/verifier' -ChildPath 'modules')
    $packageZipPath = Join-Path -Path $ModulePath -ChildPath 'GCPackages/LinuxGroupsMustExclude*.zip'
    $packageZip = Get-Item -Path $packageZipPath -errorAction SilentlyContinue
}

Describe 'Test LinuxGroupsMustExclude Package' {
    it 'Package should be available' {

        Test-Path -Path $packageZip | Should -be $true -because (gci (split-path -parent $packageZipPath))
        { Import-Module -Name GuestConfiguration -ErrorAction Stop } | Should -not -Throw
        Test-Path -Path $packageZip | Should -be $true
    }

    it 'Gets the LinuxGroupsMustExclude ''foobar'' Package Compliance Status with no params' {
        if (Get-nxLocalGroup -GroupName 'foobar')
        {
            Remove-nxLocalGroup -GroupName 'foobar' -Confirm:$false
        }

        $result = $null
        $result = Get-GuestConfigurationPackageComplianceStatus -Path $packageZip
        $result.Resources.Properties.GroupName | Should -be 'foobar'
        $result.Resources.Properties.Ensure | Should -be 'Absent'
        $result.Resources.Properties.Reasons.Phrase | Should -Match "'foobar' was not found but was expected" -Because $result.Reasons
    }

    it 'finds the newly created group ''foobar'' to be compliant' {
        if (-not (Get-nxLocalGroup -GroupName 'foobar'))
        {
            New-nxLocalGroup -GroupName foobar -ErrorAction SilentlyContinue -Confirm:$false
        }

        $result = Get-GuestConfigurationPackageComplianceStatus -Path $packageZip
        $result.complianceStatus | Should -be $true
        $result.Resources.Properties.GroupName | Should -be 'foobar'
        $result.Resources.Properties.Ensure | Should -be 'Present'
        $result.Resources.Properties.Reasons | Should -BeNullOrEmpty
    }

    it 'finds the newly created group ''foobar'' to be compliant with a parameter' {
        if (-not (Get-nxLocalGroup -GroupName 'foobar'))
        {
            New-nxLocalGroup -GroupName foobar -ErrorAction SilentlyContinue -Confirm:$false
        }

        $result = Get-GuestConfigurationPackageComplianceStatus -Path $packageZip -Parameter @{
            ResourceType = "GC_LinuxGroup"
            ResourceId = "LinuxGroupsMustExclude"
            ResourcePropertyName =  "MembersToExcludeAsString"
            ResourcePropertyValue = "anothertest;test;root"
        }

        $result.complianceStatus | Should -be $true
        $result.Resources.Properties.GroupName | Should -be 'foobar'
        $result.Resources.Properties.Ensure | Should -be 'Present'
        $result.Resources.Properties.Reasons | Should -BeNullOrEmpty
    }

    it 'finds the the group ''foobar'' not compliant when we add root & test users.' {
        if (-not (Get-nxLocalGroup -GroupName 'foobar'))
        {
            New-nxLocalGroup -GroupName 'foobar' -ErrorAction SilentlyContinue -Confirm:$false
        }

        if (-not (Get-nxLocalUser -UserName 'test'))
        {
            New-nxLocalUser -UserName 'test' -Confirm:$false -ErrorAction 'SilentlyContinue'
        }

        Add-nxLocalGroupMember -GroupName 'foobar' -UserName 'root','test'

        $result = Get-GuestConfigurationPackageComplianceStatus -Path $packageZip
        $result.complianceStatus | Should -be $false
        $result.Resources.Properties.GroupName | Should -be 'foobar'
        $result.Resources.Properties.Ensure | Should -be 'Present'
        $result.Resources.Properties.Reasons | Should -not -BeNullOrEmpty
    }

    it 'Remediates the LinuxGroupsMustExclude package by creating the group ''foobar'' with no params' { # Skipping because package is not yet set as AuditAndSet
        Start-GuestConfigurationPackageRemediation -Path $packageZip -Verbose -WarningAction SilentlyContinue
        $result = Get-GuestConfigurationPackageComplianceStatus -Path $packageZip
        $result.ComplianceStatus | Should -be $true
    }
}
