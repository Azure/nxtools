function Convert-FileSystemAccessRightToSymbol
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [System.String[]]
        [ValidateScript({$_ -as [nxFileSystemAccessRight] -or $_ -as [nxFileSystemSpecialMode]})]
        $AccessRight,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [nxFileSystemUserClass]
        [Alias('Class')]
        $UserClass,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [System.Management.Automation.SwitchParameter]
        $UseDashWhenAbsent
    )

    process {

        Write-Verbose "Access Right: '$($AccessRight -join "', '")'"

        [nxFileSystemAccessRight]$AccessRightEntry = 'none'
        [nxFileSystemSpecialMode]$SpecialModeEntry = 'none'

        $AccessRight.ForEach({
            if ($_ -as [nxFileSystemAccessRight])
            {
                $AccessRightEntry = $AccessRightEntry -bor [nxFileSystemAccessRight]$_
            }
            elseif ($_ -as [nxFileSystemSpecialMode])
            {
                $SpecialModeEntry = $SpecialModeEntry -bor [nxFileSystemSpecialMode]$_
            }
        })

        Write-Debug -Message "AccessRight: '$AccessRightEntry', SpecialMode: $SpecialModeEntry"

        $Symbols = @(
            $AccessRightEntry -band [nxFileSystemAccessRight]::Read ? 'r' : ($UseDashWhenAbsent ? '-':'')
            $AccessRightEntry -band [nxFileSystemAccessRight]::Write ? 'w' : ($UseDashWhenAbsent ? '-':'')

            if (
                $UserClass -band [nxFileSystemUserClass]::Group -and
                $SpecialModeEntry -band [nxFileSystemSpecialMode]::SetGroupId -and
                $AccessRightEntry -band [nxFileSystemAccessRight]::Execute
            )
            {
                's'
            }
            elseif (
                $UserClass -band [nxFileSystemUserClass]::Group -and
                $SpecialModeEntry -band [nxFileSystemSpecialMode]::SetGroupId
            )
            {
                'S'
            }
            elseif (
                $UserClass -band [nxFileSystemUserClass]::User -and
                $SpecialModeEntry -band [nxFileSystemSpecialMode]::SetUserId -and
                $AccessRightEntry -band [nxFileSystemAccessRight]::Execute
            )
            {
                's'
            }
            elseif (
                $UserClass -band [nxFileSystemUserClass]::User -and
                $SpecialModeEntry -band [nxFileSystemSpecialMode]::SetUserId
            )
            {
                'S'
            }
            elseif (
                $UserClass -band [nxFileSystemUserClass]::Others -and
                $SpecialModeEntry -band [nxFileSystemSpecialMode]::StickyBit -and
                $AccessRightEntry -band [nxFileSystemAccessRight]::Execute
            )
            {
                't'
            }
            elseif (
                $UserClass -band [nxFileSystemUserClass]::Others -and
                $SpecialModeEntry -band [nxFileSystemSpecialMode]::StickyBit
            )
            {
                'T'
            }
            elseif ($AccessRightEntry -band [nxFileSystemAccessRight]::Execute)
            {
                'x'
            }
            elseif ($UseDashWhenAbsent)
            {
                '-'
            }
        )

        Write-Verbose -Message "Symbols: '$($Symbols -join '')'."
        ($Symbols -join '')
    }
}
