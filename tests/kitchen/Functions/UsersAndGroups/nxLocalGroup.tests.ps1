BeforeAll {
    $ModulePath = (Join-Path -Path '/tmp/verifier' -ChildPath 'modules')
}
Describe 'Test Get-nxLocalGroup' {
    it 'Get-nxLocalGroup does not throw' {
        $allGroups = @()
        {Get-nxLocalGroup -ErrorAction Stop } | Should -Not -Throw
        $allGroups.Count | Should -not -BeNullOrEmpty
    }

    it 'List all groups' {
        Get-nxLocalGroup | Should -Not -BeNullOrEmpty
    }

    it 'finds the root group' {
        Get-nxLocalGroup -GroupName 'root' | Should -Not -BeNullOrEmpty
    }

    it 'finds groups by wildcard pattern' {
        Get-nxLocalGroup -Pattern 'roo*' | Should -Not -BeNullOrEmpty
    }

    it 'Does not find groups that do not exist' {
        Get-nxLocalGroup -GroupName 'thigroupcantexistforsure'
    }

    it 'Has the right properties for group root' {
        $rootLocalGroup = Get-nxLocalGroup -GroupName root
        $rootLocalGroup.GroupName | Should -Not -BeNullOrEmpty
        $rootLocalGroup.GroupId | Should -not -BeNullOrEmpty
        $rootLocalGroup.PSObject.Properties.Where{$_.Name -eq 'Password'} | Should -Not -BeNullOrEmpty
        $rootLocalGroup.PSObject.Properties.Where{$_.Name -eq 'GroupMember'} | Should -Not -BeNullOrEmpty
    }

    it 'has some groups with members' {
        (Get-nxLocalGroup).GroupMember.count | Should -BeGreaterThan 0
    }
}

Describe 'Test New-LocalGroup and Remove-nxLocalGroup' {
    it 'Makes sure the foobar group does not exist' {
        $foobar = Get-nxLocalGroup -GroupName 'foobar'
        if ($foobar)
        {
            Remove-nxLocalGroup -GroupName 'foobar' -Confirm:$false
        }

        Get-nxLocalGroup -GroupName 'foobar' | Should -BeNullOrEmpty
    }

    it 'Create the new foobar group' {
        {New-nxLocalGroup -GroupName 'foobar' -Confirm:$false} | Should -Not -Throw
        Get-nxLocalGroup -GroupName 'foobar' | Should -Not -BeNullOrEmpty
    }

    it 'Removes the newly created foobar group' {
        { Remove-nxLocalGroup -GroupName 'foobar' -Confirm:$false } | Should -Not -Throw
        Get-nxLocalGroup -GroupName 'foobar' | Should -BeNullOrEmpty
    }
}

Describe 'Set-nxLocalGroup' {
    it 'sets the members of newly created group' {
        if (-not (Get-nxLocalGroup -GroupName 'foobar'))
        {
            {New-nxLocalGroup -GroupName 'foobar' -Confirm:$false} | Should -Not -Throw
        }

        (Get-nxLocalGroup -GroupName 'foobar').GroupMember.Count | Should -BeLessOrEqual 0
        {Set-nxLocalGroup -Confirm:$false -GroupName 'foobar' -Member 'root'} | Should -Not -Throw
        (Get-nxLocalGroup -GroupName 'foobar').GroupMember.Count | Should -BeGreaterThan 0
    }
}
