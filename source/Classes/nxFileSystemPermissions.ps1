class nxFileSystemPermissions
{
    hidden static [string] $SymbolicTriadParser = '^[-dl]?(?<User>[-wrxsStT]{3})(?<Group>[-wrxsStT]{3})(?<Others>[-wrxsStT]{3})$'
    hidden static [string] $SymbolicOperationParser = '^(?<userClass>[ugoa]{1,3})(?<operator>[\-\+\=]{1})(?<permissions>[wrxTtSs-]{1,3})$'
    [nxFileSystemSpecialMode]  $SpecialModeFlags
    [nxFileSystemAccessRight]  $OwnerPermission
    [nxFileSystemAccessRight]  $GroupPermission
    [nxFileSystemAccessRight]  $OthersPermission

    nxFileSystemPermissions()
    {
        # default ctor, can be used like this:
        <#
            [nxFileSystemPermissions]@{
                SpecialModeFlags = 'None'
                OwnerPermission  = 'Read, Write, Execute'
                GroupPermission  = 'Read, Execute'
                OthersPermission = 7
            }
        #>
    }

    nxFileSystemPermissions([String]$Permissions)
    {
        if ($Permissions -match '^\d{3,4}$')
        {
            # Convert from Int to nxFileSystemAccessRight
            $this.setNxFileSystemPermissionFromInt([int]::Parse($Permissions))
        }
        elseif ($Permissions -cmatch [nxFileSystemPermissions]::SymbolicTriadParser)
        {
            $this.setNxFileSystemPermissionFromSymbolicTriadNotation($Permissions)
        }
        elseif (-not ($Permissions -split '\s+').Where{$_ -cnotmatch [nxFileSystemPermissions]::SymbolicOperationParser})
        {
            # All items of the space delimited Symbolic operations have been checked.
            $this.DoSymbolicChmodOperation($Permissions)
        }
        else
        {
            throw "The symbolic string '$Permissions' is invalid."
        }
    }

    nxFileSystemPermissions([int]$Permissions)
    {
        $this.setNxFileSystemPermissionFromInt($Permissions)
    }

    hidden [void] setNxFileSystemPermissionFromSymbolicTriadNotation([string]$SymbolicTriad)
    {
        $null = $SymbolicTriad -cmatch [nxFileSystemPermissions]::SymbolicTriadParser

        $this.DoSymbolicChmodOperation(@(
            ('u=' + $Matches['User'])
            ('g=' + $Matches['Group'])
            ('o=' + $Matches['Others'])
        ) -join ' ')
    }

    hidden [void] setNxFileSystemPermissionFromInt([Int]$Permissions)
    {
        # Adding leading 0s to ensure we have a 0 for the special flags i.e. 777 -> 0777
        $StringPermission = "{0:0000}" -f $Permissions
        Write-Debug -Message "Trying to parse the permission set expressed by '$($Permissions)'."

        if ($StringPermission.Length -gt 4)
        {
            throw "Permission set should be expressed with 4 or 3 digits (you can omit the one on the left): setuid(4)/setgid(2)/sticky bit(1)|Owner|Group|Others). '$($StringPermission)'"
        }

        Write-Debug -Message "Parsing Special Mode Flags: $([int]::Parse($StringPermission[0]))"
        $this.SpecialModeFlags = [int]::Parse($StringPermission[0])
        $this.OwnerPermission  = [int]::Parse($StringPermission[1])
        $this.GroupPermission  = [int]::Parse($StringPermission[2])
        $this.OthersPermission = [int]::Parse($StringPermission[3])
    }

    [void] DoChmodOperation ([nxFileSystemUserClass]$UserClass, [char]$Operator, [nxFileSystemAccessRight]$AccessRights, [nxFileSystemSpecialMode]$SpecialMode)
    {
        switch ($operator)
        {
            '=' {
                $this.SetMode($userClass, $accessRights, $specialMode)
            }

            '+'
            {
                $this.AddMode($userClass, $accessRights, $specialMode)
            }

            '-'
            {
                $this.RemoveMode($userClass, $accessRights, $specialMode)
            }

            default
            {
                throw "Operator not recognised '$operator'."
            }
        }
    }

    [void] DoSymbolicChmodOperation ([string]$SymbolicChmodString)
    {
        $symbolicChmodList = $SymbolicChmodString -split '\s+'

        foreach ($symbolicChmodStringItem in $symbolicChmodList)
        {
            Write-Debug -Message "Doing Symbolic Operation '$symbolicChmodStringItem'."
            if ($symbolicChmodStringItem -match [nxFileSystemPermissions]::SymbolicOperationParser)
            {
                $userClassChars = $Matches['userClass']
                $operator       = $Matches['operator']
                $permissions    = $Matches['permissions']
                $userClass      = [nxFileSystemUserClass](Convert-CharToNxFileSystemUserClass -Char $userClassChars)
                Write-Debug -Message "Parsing $permissions"
                $specialMode    = [nxFileSystemSpecialMode](Convert-CharToNxFileSystemSpecialMode -SpecialModeSymbol $permissions -UserClass $UserClass)
                $accessRights   = [nxFileSystemAccessRight](Convert-CharToNxFileSystemAccessRight -AccessRightSymbol $permissions)

                $this.DoChmodOperation($userClass, $operator, $accessRights, $specialMode)
            }
        }
    }

    [void] SetMode ([nxFileSystemUserClass]$UserClass, [nxFileSystemAccessRight]$AccessRights, [nxFileSystemSpecialMode]$SpecialMode)
    {
        Write-Debug -Message "Setting rights '$($AccessRights)' and special flag '$($SpecialMode)' to '$($UserClass)'"
        switch ($UserClass)
        {
            { $_ -band [nxFileSystemUserClass]::User } {
                $this.OwnerPermission = $AccessRights
            }

            { $_ -band [nxFileSystemUserClass]::Group } {
                $this.GroupPermission = $AccessRights
            }

            { $_ -band [nxFileSystemUserClass]::Others } {
                $this.OthersPermission = $AccessRights
            }

            default {
                throw "Error with unrecognized User Class '$UserClass'."
            }
        }

        $this.SpecialModeFlags = $SpecialMode
    }

    [void] AddMode ([nxFileSystemUserClass]$UserClass, [nxFileSystemAccessRight]$AccessRights, [nxFileSystemSpecialMode]$SpecialMode)
    {
        Write-Debug -Message "Adding rights '$($AccessRights)' and special flag '$($SpecialMode)' to '$($UserClass)'"
        switch ($UserClass)
        {
            { $_ -band [nxFileSystemUserClass]::User } {
                $this.OwnerPermission = $this.OwnerPermission -bor $AccessRights
            }

            { $_ -band [nxFileSystemUserClass]::Group } {
                $this.GroupPermission = $this.GroupPermission -bor $AccessRights
            }

            { $_ -band [nxFileSystemUserClass]::Others } {
                $this.OthersPermission = $this.OthersPermission -bor $AccessRights
            }

            default {
                throw "Error with unrecognized User Class '$UserClass'."
            }
        }

        $this.SpecialModeFlags = $this.SpecialModeFlags -bor $SpecialMode
    }

    [void] RemoveMode ([nxFileSystemUserClass]$UserClass, [nxFileSystemAccessRight]$AccessRights, [nxFileSystemSpecialMode]$SpecialMode)
    {
        Write-Debug -Message "Removing rights '$($AccessRights)' and special flag '$($SpecialMode)' to '$($UserClass)'"
        switch ($UserClass)
        {
            { $_ -band [nxFileSystemUserClass]::User } {
                $this.OwnerPermission = $this.OwnerPermission -band -bnot $AccessRights
            }

            { $_ -band [nxFileSystemUserClass]::Group } {
                $this.GroupPermission = $this.GroupPermission -band -bnot $AccessRights
            }

            { $_ -band [nxFileSystemUserClass]::Others } {
                $this.OthersPermission = $this.OthersPermission -band -bnot $AccessRights
            }

            default {
                throw "Error with unrecognized User Class '$UserClass'."
            }
        }

        $this.SpecialModeFlags = $this.SpecialModeFlags -band -bnot $SpecialMode
    }

    [string] ToString()
    {
        Write-Verbose -Message "$($this.OwnerPermission)"
        Write-Verbose -Message "$(@($this.OthersPermission, $this.SpecialModeFlags) -join '|')"

        $SymbolNotation = [PSCustomObject]@{
            UserClass         = [nxFileSystemUserClass]::User
            AccessRight       = $this.OwnerPermission
            UseDashWhenAbsent = $true
        },
        [PSCustomObject]@{
            UserClass         = [nxFileSystemUserClass]::Group
            AccessRight       = $this.GroupPermission
            UseDashWhenAbsent = $true
        },
        [PSCustomObject]@{
            UserClass         = [nxFileSystemUserClass]::User
            AccessRight       = $this.OthersPermission
            UseDashWhenAbsent = $true
        } | Convert-FileSystemAccessRightToSymbol

        Write-Verbose -Message "SymbolNotation: $SymbolNotation"
        return ($SymbolNotation -join '')
    }
}
