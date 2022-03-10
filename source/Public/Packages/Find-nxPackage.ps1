function Find-nxPackage
{
    [CmdletBinding()]
    [OutputType()]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        # Name of the Package fo find in the Cached list of packages. Make sure you update the cache as needed.
        $Name,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        # Specifc Version of a package that you want to find in the Cached list of packages.
        $Version,

        [Parameter()]
        [switch]
        # Show all versions available for a package.
        $AllVersions,

        [Parameter()]
        [nxSupportedPackageType[]]
        $PackageType = (Get-nxSupportedPackageType)
    )

    begin
    {
        # Work out the $PackageType priority
        # for Find prefer in order: dnf, yum, apt, zapper, snap
        $PackageTypeStrings = [string[]]($PackageType.Foreach({$_.ToString()}))
        $packageTypeToUseInPriority = @('dnf', 'yum', 'apt', 'zapper', 'snap').Where{$_ -in $PackageTypeStrings} | Select-Object -First 1
        Write-Debug -Message "The package type to use in priority to list packages is '$packageTypeToUseInPriority'."
    }

    end
    {
        if ($PSBoundParameters.ContainsKey('PackageType'))
        {
            $null = $PSBoundParameters.Remove('PackageType')
        }

        switch ($packageTypeToUseInPriority)
        {
            'dpkg' { Find-nxAptPackageFromCache @PSBoundParameters }
            'apt'  { Find-nxAptPackageFromCache @PSBoundParameters }
            'yum'  { Find-nxYumPackage @PSBoundParameters }

            default
            {
                throw ('The Package type {0} is not yet supported with ''Find-nxPackage''.' -f $packageTypeToUseInPriority)
            }
        }
    }
}
