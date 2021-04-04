function Convert-nxFileSystemModeComparisonToSymbolicOperation
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('Class')]
        [nxFileSystemUserClass]
        $UserClass,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [System.String]
        [ValidateScript({$_ -as [nxFileSystemAccessRight] -or $_ -as [nxFileSystemSpecialMode]})]
        [Alias('InputObject')]
        $EnumValue,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        $SideIndicator
    )

    process {
        # FTR the side indicator points where the EnumValue is found: REFERENCE <=> DIFFERENCE
        # The SympolicOperation generated aims to make the DifferenceMode compliante with the reference.

        Write-Debug "[$UserClass] [$EnumValue] [$SideIndicator]"

        if ($SideIndicator -eq '<=')
        {
            # Need to add something that is not in the reference
            $operator = '+'
        }
        else
        {
            # Need to remove something that is not in the reference
            $operator = '-'
        }

        $UserClassSymbol = Convert-nxFileSystemUserClassToSymbol -UserClass $UserClass
        $ModeSymbol = Convert-nxFileSystemAccessRightToSymbol -AccessRight $EnumValue -UserClass $UserClass

        return ('{0}{1}{2}' -f $UserClassSymbol, $operator, $ModeSymbol)
    }
}
