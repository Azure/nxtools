function Compare-FileSystemPermission
{
    [CmdletBinding()]
    [OutputType([hashtable])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [nxFileSystemPermissions]
        $ReferencePermission,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [nxFileSystemPermissions[]]
        [Alias('nxFileSystemAccessRight')]
        $DifferencePermission,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]
        [Alias('FullName', 'Path')]
        $DifferencePath,

        [Parameter()]
        [Switch]
        $IncludeEqual
    )

    process {
        foreach ($PermissionItem in $DifferencePermission)
        {
            Write-Verbose -Message "Comparing '$ReferencePermission' with '$PermissionItem'"

            $diffOwner = $ReferencePermission.OwnerPermission -bxor $PermissionItem.OwnerPermission
            $diffGroup = $ReferencePermission.GroupPermission -bxor $PermissionItem.GroupPermission
            $diffOthers = $ReferencePermission.OthersPermission -bxor $PermissionItem.OthersPermission
            $diffSpecialModeFlags = $ReferencePermission.SpecialModeFlags -bxor $PermissionItem.SpecialModeFlags

            foreach ($enumValue in ([Enum]::GetValues([nxFileSystemAccessRight]).Where({$_ -ne [nxFileSystemAccessRight]::None})))
            {
                if ($diffOwner -band $enumValue)
                {
                    $sideIndicator = $ReferencePermission.OwnerPermission -band $enumValue ? '<=' : '=>'
                    Write-Verbose -Message "[$([nxFileSystemUserClass]::User)]'$enumValue' is only on this side [REF '$sideIndicator' DIFF]."
                    [PSCustomObject]@{
                        Class                = [nxFileSystemUserClass]::User
                        InputObject          = $enumValue
                        SideIndicator        = $sideIndicator
                        DifferencePath       = $DifferencePath
                    } | Add-Member -PassThru -Name RemediationOperation -MemberType ScriptProperty -Value {$this | Convert-FileSystemPermissionComparisonToSymbolicOperation}
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
                    $sideIndicator = $ReferencePermission.GroupPermission -band $enumValue ? '<=' : '=>'
                    Write-Verbose -Message "[$([nxFileSystemUserClass]::Group)]'$enumValue' is only on this side [REF '$sideIndicator' DIFF]."
                    [PSCustomObject]@{
                        Class                = [nxFileSystemUserClass]::Group
                        InputObject          = $enumValue
                        SideIndicator        = $sideIndicator
                        DifferencePath       = $DifferencePath
                    } | Add-Member -PassThru -Name RemediationOperation -MemberType ScriptProperty -Value {$this | Convert-FileSystemPermissionComparisonToSymbolicOperation}
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
                    $sideIndicator = $ReferencePermission.OthersPermission -band $enumValue ? '<=' : '=>'
                    Write-Verbose -Message "[$([nxFileSystemUserClass]::Others)]'$enumValue' is only on this side [REF '$sideIndicator' DIFF]."
                    [PSCustomObject]@{
                        Class                = [nxFileSystemUserClass]::Others
                        InputObject          = $enumValue
                        SideIndicator        = $sideIndicator
                        DifferencePath       = $DifferencePath
                    } | Add-Member -PassThru -Name RemediationOperation -MemberType ScriptProperty -Value {$this | Convert-FileSystemPermissionComparisonToSymbolicOperation}
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
                    $sideIndicator = $ReferencePermission.SpecialModeFlags -band $enumValue ? '<=' : '=>'
                    Write-Verbose -Message "[$([nxFileSystemUserClass]::None)]'$enumValue' is only on this side [REF '$sideIndicator' DIFF]."
                    [PSCustomObject]@{
                        Class                = [nxFileSystemUserClass]::None
                        InputObject          = $enumValue
                        SideIndicator        = $sideIndicator
                        DifferencePath       = $DifferencePath
                    } | Add-Member -PassThru -Name RemediationOperation -MemberType ScriptProperty -Value {$this | Convert-FileSystemPermissionComparisonToSymbolicOperation}
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
