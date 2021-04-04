function Compare-nxMode
{
    [CmdletBinding()]
    [OutputType([hashtable])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [nxFileSystemMode]
        $ReferenceMode,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [nxFileSystemMode[]]
        [Alias('Mode')]
        $DifferenceMode,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]
        [Alias('FullName', 'Path')]
        $DifferencePath,

        [Parameter()]
        [Switch]
        $IncludeEqual
    )

    process {
        foreach ($ModeItem in $DifferenceMode)
        {
            Write-Verbose -Message "Comparing '$ReferenceMode' with '$ModeItem'"

            $diffOwner = $ReferenceMode.OwnerMode -bxor $ModeItem.OwnerMode
            $diffGroup = $ReferenceMode.GroupMode -bxor $ModeItem.GroupMode
            $diffOthers = $ReferenceMode.OthersMode -bxor $ModeItem.OthersMode
            $diffSpecialModeFlags = $ReferenceMode.SpecialModeFlags -bxor $ModeItem.SpecialModeFlags

            foreach ($enumValue in ([Enum]::GetValues([nxFileSystemAccessRight]).Where({$_ -ne [nxFileSystemAccessRight]::None})))
            {
                if ($diffOwner -band $enumValue)
                {
                    $sideIndicator = $ReferenceMode.OwnerMode -band $enumValue ? '<=' : '=>'
                    Write-Verbose -Message "[$([nxFileSystemUserClass]::User)]'$enumValue' is only on this side [REF '$sideIndicator' DIFF]."
                    [PSCustomObject]@{
                        Class                = [nxFileSystemUserClass]::User
                        InputObject          = $enumValue
                        SideIndicator        = $sideIndicator
                        DifferencePath       = $DifferencePath
                    } | Add-Member -PassThru -Name RemediationOperation -MemberType ScriptProperty -Value {$this | Convert-nxFileSystemModeComparisonToSymbolicOperation}
                }
                elseif ($IncludeEqual)
                {
                    [PSCustomObject]@{
                        Class                = [nxFileSystemUserClass]::User
                        InputObject          = $enumValue
                        SideIndicator        = '='
                        RemediationOperation = ''
                        DifferencePath       = $DifferencePath
                    }
                }

                if ($diffGroup -band $enumValue)
                {
                    $sideIndicator = $ReferenceMode.GroupMode -band $enumValue ? '<=' : '=>'
                    Write-Verbose -Message "[$([nxFileSystemUserClass]::Group)]'$enumValue' is only on this side [REF '$sideIndicator' DIFF]."
                    [PSCustomObject]@{
                        Class                = [nxFileSystemUserClass]::Group
                        InputObject          = $enumValue
                        SideIndicator        = $sideIndicator
                        DifferencePath       = $DifferencePath
                    } | Add-Member -PassThru -Name RemediationOperation -MemberType ScriptProperty -Value {$this | Convert-nxFileSystemModeComparisonToSymbolicOperation}
                }
                elseif ($IncludeEqual)
                {
                    [PSCustomObject]@{
                        Class                = [nxFileSystemUserClass]::Group
                        InputObject          = $enumValue
                        SideIndicator        = '='
                        RemediationOperation = ''
                        DifferencePath       = $DifferencePath
                    }
                }

                if ($diffOthers -band $enumValue)
                {
                    $sideIndicator = $ReferenceMode.OthersMode -band $enumValue ? '<=' : '=>'
                    Write-Verbose -Message "[$([nxFileSystemUserClass]::Others)]'$enumValue' is only on this side [REF '$sideIndicator' DIFF]."
                    [PSCustomObject]@{
                        Class                = [nxFileSystemUserClass]::Others
                        InputObject          = $enumValue
                        SideIndicator        = $sideIndicator
                        DifferencePath       = $DifferencePath
                    } | Add-Member -PassThru -Name RemediationOperation -MemberType ScriptProperty -Value {$this | Convert-nxFileSystemModeComparisonToSymbolicOperation}
                }
                elseif ($IncludeEqual)
                {
                    [PSCustomObject]@{
                        Class                = [nxFileSystemUserClass]::Others
                        InputObject          = $enumValue
                        SideIndicator        = '='
                        RemediationOperation = ''
                        DifferencePath       = $DifferencePath
                    }
                }
            }

            foreach ($enumValue in ([Enum]::GetValues([nxFileSystemSpecialMode])))
            {
                if ($diffSpecialModeFlags -band $enumValue)
                {
                    $sideIndicator = $ReferenceMode.SpecialModeFlags -band $enumValue ? '<=' : '=>'
                    Write-Verbose -Message "[$([nxFileSystemUserClass]::None)]'$enumValue' is only on this side [REF '$sideIndicator' DIFF]."
                    [PSCustomObject]@{
                        Class                = [nxFileSystemUserClass]::None
                        InputObject          = $enumValue
                        SideIndicator        = $sideIndicator
                        DifferencePath       = $DifferencePath
                    } | Add-Member -PassThru -Name RemediationOperation -MemberType ScriptProperty -Value {$this | Convert-nxFileSystemModeComparisonToSymbolicOperation}
                }
                elseif ($IncludeEqual)
                {
                    [PSCustomObject]@{
                        Class                = [nxFileSystemUserClass]::None
                        InputObject          = $enumValue
                        SideIndicator        = '='
                        RemediationOperation = ''
                        DifferencePath       = $DifferencePath
                    }
                }
            }
        }
    }
}
