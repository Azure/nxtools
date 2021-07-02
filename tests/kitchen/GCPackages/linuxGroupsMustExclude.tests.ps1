BeforeAll {
    $ProgressPreference = 'SilentlyContinue'
    $ErrorActionPreference = 'Continue'
    $ModulePath = (Join-Path -Path '/tmp/verifier' -ChildPath 'modules')
    $packageZipPath = Join-Path -Path $ModulePath -ChildPath 'GCPolicyPackages/LinuxGroupsMustExclude*.zip'
    $packageZip = Get-Item -Path $packageZipPath -errorAction SilentlyContinue
}
Describe 'Test LinuxGroupsMustExcludt Audit Package' {
    it 'Package should be available' {

        Test-Path -Path $packageZip | Should -be $true -because (gci (split-path -parent $packageZipPath))
        { Import-Module -Name GuestConfiguration -ErrorAction Stop } | Should -not -Throw
        { Install-GuestConfigurationAgent -ErrorAction Stop -Force } | Should -not -Throw
        { Install-GuestConfigurationPackage -Force -Path $packageZip } | Should -not -Throw
    }

    it 'Gets the LinuxGroupsMustExclude ''foobar'' Package Compliance Status with no params' {
        if (Get-nxLocalGroup -GroupName 'foobar')
        {
            Remove-nxLocalGroup -GroupName 'foobar' -Confirm:$false
        }

        $result = $null
        $result = Get-GuestConfigurationPackageComplianceStatus -Package $packageZip
        $result.Resources.GroupName | Should -be 'foobar'
        $result.Resources.Ensure | Should -be 'Absent'
        $result.Resources.Reasons.Phrase | Should -Match "'foobar' was not found but was expected" -Because $result.Reasons
    }

    it 'finds the newly created group ''foobar'' to be compliant' {
        if (-not (Get-nxLocalGroup -GroupName 'foobar'))
        {
            New-nxLocalGroup -GroupName foobar -ErrorAction SilentlyContinue -Confirm:$false
        }

        $result = Get-GuestConfigurationPackageComplianceStatus -Package $packageZip
        $result.complianceStatus | Should -be $true
        $result.Resources.GroupName | Should -be 'foobar'
        $result.Resources.Ensure | Should -be 'Present'
        $result.Resources.Reasons | Should -BeNullOrEmpty
    }

    it 'finds the newly created group ''foobar'' to be compliant with a parameter' {
        if (-not (Get-nxLocalGroup -GroupName 'foobar'))
        {
            New-nxLocalGroup -GroupName foobar -ErrorAction SilentlyContinue -Confirm:$false
        }

        $result = Get-GuestConfigurationPackageComplianceStatus -Package $packageZip -Parameter @{
            ResourceType = "GC_LinuxGroup"
            ResourceId = "LinuxGroupsMustExclude"
            ResourcePropertyName =  "MembersToExcludeAsString"
            ResourcePropertyValue = "anothertest;test;root"
        }

        $result.complianceStatus | Should -be $true
        $result.Resources.GroupName | Should -be 'foobar'
        $result.Resources.Ensure | Should -be 'Present'
        $result.Resources.Reasons | Should -BeNullOrEmpty
    }

    it 'finds the the group ''foobar'' not compliant when we add root & test users.' {
        if (-not (Get-nxLocalGroup -GroupName 'foobar'))
        {
            New-nxLocalGroup -GroupName foobar -ErrorAction SilentlyContinue -Confirm:$false
        }

        Add-nxLocalGroupMember -GroupName 'foobar' -UserName 'root','test'

        $result = Get-GuestConfigurationPackageComplianceStatus -Package $packageZip
        $result.complianceStatus | Should -be $false
        $result.Resources.GroupName | Should -be 'foobar'
        $result.Resources.Ensure | Should -be 'Present'
        $result.Resources.Reasons | Should -not -BeNullOrEmpty
    }

    it 'Remediates the LinuxGroupsMustInclude package by creating the group ''foobar'' with no params' -skip { # Skipping because package is not yet set as AuditAndSet
        Start-GuestConfigurationPackageRemediation -Package $packageZip
        $result = Get-GuestConfigurationPackageComplianceStatus -Package $packageZip -verbose
        $result.ComplianceStatus | Should -be $true
    }
}
