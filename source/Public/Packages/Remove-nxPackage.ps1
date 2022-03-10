function Remove-nxPackage
{
    [CmdletBinding()]
    [OutputType([void])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string[]]
        # List of Packages to remove from the system.
        $Name,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]
        $Version,

        [Parameter()]
        [nxSupportedPackageType[]]
        $PackageType = (Get-nxSupportedPackageType)
    )

    begin
    {
        # Work out the $PackageType priority
        # for Find prefer in order: dnf, yum, apt, zapper, snap
        $PackageTypeStrings = [string[]]($PackageType.Foreach({$_.ToString()}))
        $packageTypeToUseInPriority = @('dnf', 'yum', 'apt', 'zapper', 'snap','dpkg').Where{$_ -in $PackageTypeStrings} | Select-Object -First 1
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
            'dpkg' { Remove-nxAptPackage @PSBoundParameters }
            'apt'  { Remove-nxAptPackage @PSBoundParameters }
            'yum'  { Remove-nxYumPackage @PSBoundParameters  }

            default
            {
                throw ('The Package type {0} is not yet supported with ''Remove-nxPackage''.' -f $packageTypeToUseInPriority)
            }
        }
    }
}
