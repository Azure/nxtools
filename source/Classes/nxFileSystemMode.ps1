class nxFileSystemMode
{
    hidden static [string] $SymbolicTriadParser = '^[-dlsp]?(?<User>[-wrxsStT]{3})(?<Group>[-wrxsStT]{3})(?<Others>[-wrxsStT]{3})$'
    hidden static [string] $SymbolicOperationParser = '^(?<userClass>[ugoa]{1,3})(?<operator>[\-\+\=]{1})(?<permissions>[wrxTtSs-]{1,3})$'
    [nxFileSystemSpecialMode]  $SpecialModeFlags
    [nxFileSystemAccessRight]  $OwnerMode
    [nxFileSystemAccessRight]  $GroupMode
    [nxFileSystemAccessRight]  $OthersMode

    nxFileSystemMode()
    {
        # default ctor, can be used like this:
        <#
            [nxFileSystemMode]@{
                SpecialModeFlags = 'None'
                OwnerMode  = 'Read, Write, Execute'
                GroupMode  = 'Read, Execute'
                OthersMode = 7
            }
        #>
    }

    nxFileSystemMode([String]$Modes)
    {
        if ($Modes -match '^\d{3,4}$')
        {
            # Convert from Int to nxFileSystemAccessRight
            $this.setNxFileSystemModeFromInt([int]::Parse($Modes))
        }
        elseif ($Modes -cmatch [nxFileSystemMode]::SymbolicTriadParser)
        {
            $this.setNxFileSystemModeFromSymbolicTriadNotation($Modes)
        }
        elseif (-not ($Modes -split '\s+').Where{$_ -cnotmatch [nxFileSystemMode]::SymbolicOperationParser})
        {
            # All items of the space delimited Symbolic operations have been checked.
            $this.DoSymbolicChmodOperation($Modes)
        }
        else
        {
            throw "The symbolic string '$Modes' is invalid."
        }
    }

    nxFileSystemMode([int]$Modes)
    {
        $this.setNxFileSystemModeFromInt($Modes)
    }

    hidden [void] setNxFileSystemModeFromSymbolicTriadNotation([string]$SymbolicTriad)
    {
        $null = $SymbolicTriad -cmatch [nxFileSystemMode]::SymbolicTriadParser

        $this.DoSymbolicChmodOperation(@(
            ('u=' + $Matches['User'])
            ('g=' + $Matches['Group'])
            ('o=' + $Matches['Others'])
        ) -join ' ')
    }

    hidden [void] setNxFileSystemModeFromInt([Int]$Modes)
    {
        # Adding leading 0s to ensure we have a 0 for the special flags i.e. 777 -> 0777
        $StringMode = "{0:0000}" -f $Modes
        Write-Debug -Message "Trying to parse the permission set expressed by '$($Modes)'."

        if ($StringMode.Length -gt 4)
        {
            throw "Mode set should be expressed with 4 or 3 digits (you can omit the one on the left): setuid(4)/setgid(2)/sticky bit(1)|Owner|Group|Others). '$($StringMode)'"
        }

        Write-Debug -Message "Parsing Special Mode Flags: $([int]::Parse($StringMode[0]))"
        $this.SpecialModeFlags = [int]::Parse($StringMode[0])
        $this.OwnerMode  = [int]::Parse($StringMode[1])
        $this.GroupMode  = [int]::Parse($StringMode[2])
        $this.OthersMode = [int]::Parse($StringMode[3])
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
            if ($symbolicChmodStringItem -match [nxFileSystemMode]::SymbolicOperationParser)
            {
                $userClassChars = $Matches['userClass']
                $operator       = $Matches['operator']
                $permissions    = $Matches['permissions']
                $userClass      = [nxFileSystemUserClass](Convert-nxSymbolToFileSystemUserClass -Char $userClassChars)
                Write-Debug -Message "Parsing $permissions"
                $specialMode    = [nxFileSystemSpecialMode](Convert-nxSymbolToFileSystemSpecialMode -SpecialModeSymbol $permissions -UserClass $UserClass)
                $accessRights   = [nxFileSystemAccessRight](Convert-nxSymbolToFileSystemAccessRight -AccessRightSymbol $permissions)

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
                $this.OwnerMode = $AccessRights
            }

            { $_ -band [nxFileSystemUserClass]::Group } {
                $this.GroupMode = $AccessRights
            }

            { $_ -band [nxFileSystemUserClass]::Others } {
                $this.OthersMode = $AccessRights
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
                $this.OwnerMode = $this.OwnerMode -bor $AccessRights
            }

            { $_ -band [nxFileSystemUserClass]::Group } {
                $this.GroupMode = $this.GroupMode -bor $AccessRights
            }

            { $_ -band [nxFileSystemUserClass]::Others } {
                $this.OthersMode = $this.OthersMode -bor $AccessRights
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
                $this.OwnerMode = $this.OwnerMode -band -bnot $AccessRights
            }

            { $_ -band [nxFileSystemUserClass]::Group } {
                $this.GroupMode = $this.GroupMode -band -bnot $AccessRights
            }

            { $_ -band [nxFileSystemUserClass]::Others } {
                $this.OthersMode = $this.OthersMode -band -bnot $AccessRights
            }

            default {
                throw "Error with unrecognized User Class '$UserClass'."
            }
        }

        $this.SpecialModeFlags = $this.SpecialModeFlags -band -bnot $SpecialMode
    }

    [string] ToString()
    {
        Write-Verbose -Message "$($this.OwnerMode)"
        Write-Verbose -Message "$(@($this.OthersMode, $this.SpecialModeFlags) -join '|')"

        $SymbolNotation = [PSCustomObject]@{
            UserClass         = [nxFileSystemUserClass]::User
            AccessRight       = $this.OwnerMode
            UseDashWhenAbsent = $true
        },
        [PSCustomObject]@{
            UserClass         = [nxFileSystemUserClass]::Group
            AccessRight       = $this.GroupMode
            UseDashWhenAbsent = $true
        },
        [PSCustomObject]@{
            UserClass         = [nxFileSystemUserClass]::User
            AccessRight       = $this.OthersMode
            UseDashWhenAbsent = $true
        } | Convert-nxFileSystemAccessRightToSymbol

        Write-Verbose -Message "SymbolNotation: $SymbolNotation"
        return ($SymbolNotation -join '')
    }

    [string] ToOctal()
    {
        return ('{0}{1}{2}{3}' -f (
            ([int]$this.SpecialModeFlags),
            ([int]$this.OwnerMode),
            ([int]$this.GroupMode),
            ([int]$this.OthersMode)
        ))
    }
}
