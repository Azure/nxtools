
function Get-nxPackage
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [String[]]
        $Name,

        [Parameter()]
        [nxSupportedPackageType[]]
        $PackageType = (Get-nxSupportedPackageType)
    )

    # Work out the $PackageType priority
    # for GET prefer in order: dpkg, dnf, yum, apt, zapper, snap
    $PackageTypeStrings = [string[]]($PackageType.Foreach({$_.ToString()}))
    $packageTypeToUseInPriority = @('dpkg', 'dnf', 'yum', 'apt', 'zapper', 'snap').Where{$_ -in $PackageTypeStrings} | Select-Object -First 1
    Write-Debug -Message "The package type to use in priority to list packages is '$packageTypeToUseInPriority'."

    switch ($packageTypeToUseInPriority)
    {
        'dpkg' { Get-nxDpkgPackage -Name $Name -ErrorAction Ignore }
        'yum'  { Get-nxYumPackage -Name $Name -ErrorAction Ignore }

        default
        {
            throw ('The Package type {0} is not yet supported with ''Get-nxPackage''.' -f $packageTypeToUseInPriority)
        }
    }
}
