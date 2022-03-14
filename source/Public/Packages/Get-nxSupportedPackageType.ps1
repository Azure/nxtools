
function Get-nxSupportedPackageType
{
    [CmdletBinding()]
    [OutputType([string[]])]
    param
    (
        [Parameter()]
        [nxSupportedPackageType[]]
        $PackageType = [Enum]::GetNames([nxSupportedPackageType])
    )

    $packageUtilFound = Get-Command -Name @($PackageType.Foreach({$_.ToString()})) -ErrorAction Ignore

    return $packageUtilFound.Name
}
