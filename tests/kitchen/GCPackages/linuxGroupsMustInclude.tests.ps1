BeforeAll {
    $ProgressPreference = 'SilentlyContinue'
    $ErrorActionPreference = 'Continue'
    $ModulePath = (Join-Path -Path '/tmp/verifier' -ChildPath 'modules')
    $packageZipPath = Join-Path -Path $ModulePath -ChildPath 'GCPackages/LinuxGroupsMustInclude*.zip'
    $packageZip = Get-Item -Path $packageZipPath -errorAction SilentlyContinue
}

Describe 'Test Groups Must Include GC Package' {
    it 'Package is available and GC module installs Agent and Package' {

        Test-Path -Path $packageZip | Should -be $true -because (gci (split-path -parent $packageZipPath))
        { Import-Module -Name GuestConfiguration -ErrorAction Stop } | Should -not -Throw
        Test-Path -Path $packageZip | Should -be $true
        # Get-ChildItem -File $ModulePath | Should -not -BeNullOrEmpty -Because (Get-ChildItem $PWD.Path -Recurse)

    }

    it 'Does not find the nxLocalGroup Group ''foobar'' (with no params)' {
        if (Get-nxLocalGroup -GroupName 'foobar')
        {
            Remove-nxLocalGroup -GroupName 'foobar' -Confirm:$false
        }

        $result = $null
        $result = Get-GuestConfigurationPackageComplianceStatus -Path $packageZip
        $result.Resources.Properties.GroupName | Should -be 'foobar'
        $result.Resources.Properties.Ensure | Should -be 'Absent'
    }

    it 'Does not find the nxLocalGroup Group ''barfoo'' (with parameter to override groupname)' {
        if (Get-nxLocalGroup -GroupName 'barfoo')
        {
            Remove-nxLocalGroup -GroupName 'barfoo' -Confirm:$false
        }

        $result = $null
        $result = Get-GuestConfigurationPackageComplianceStatus -Path $packageZip -Parameter @{
            ResourceType = "GC_LinuxGroup"
            ResourceId = "LinuxGroupsMustInclude"
            ResourcePropertyName =  "GroupName"
            ResourcePropertyValue = "barfoo"
        }

        $result.Resources.Properties.GroupName | Should -be 'barfoo'
        $result.Resources.Properties.Ensure | Should -be 'Absent'
    }

    it 'finds the newly created group ''foobar'' with Parameters ' {
        if (-not (Get-nxLocalGroup -GroupName 'foobar'))
        {
            New-nxLocalGroup -GroupName foobar -ErrorAction SilentlyContinue -Confirm:$false
        }

        if (-not (Get-nxLocalUser -UserName 'test'))
        {
            New-nxLocalUser -UserName 'test' -Confirm:$false -ErrorAction SilentlyContinue
        }

        Add-nxLocalGroupMember -GroupName 'foobar' -UserName 'root'
        Add-nxLocalGroupMember -GroupName 'foobar' -UserName 'test'

        $result = Get-GuestConfigurationPackageComplianceStatus -Path $packageZip -Parameter @(
            @{
                ResourceType = "GC_LinuxGroup"
                ResourceId = "LinuxGroupsMustInclude"
                ResourcePropertyName =  "MembersToIncludeAsString"
                ResourcePropertyValue = "test;root"
            },
            @{
                ResourceType = "GC_LinuxGroup"
                ResourceId = "LinuxGroupsMustInclude"
                ResourcePropertyName =  "GroupName"
                ResourcePropertyValue = "foobar"
            }
        )

        $result.Resources.Properties.GroupName | Should -be 'foobar'
        $result.Resources.Properties.Ensure | Should -be 'Present'
        $result.Resources.Properties.Reasons | Should -BeNullOrEmpty
    }

    it 'Remediates the LinuxGroupsMustInclude package by creating the group ''foobar'' with no params' { # Skipping because package is not yet set as AuditAndSet
        Start-GuestConfigurationPackageRemediation -Path $packageZip
        $result = Get-GuestConfigurationPackageComplianceStatus -Path $packageZip -verbose
        $result.ComplianceStatus | Should -be $true
    }
}
