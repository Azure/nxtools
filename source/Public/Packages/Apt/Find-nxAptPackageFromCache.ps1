function Find-nxAptPackageFromCache
{
    [CmdletBinding()]
    [OutputType([nxAptPackage])]
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
        $AllVersions
    )

    begin
    {
        $verbose = $VerbosePreference -ne 'SilentlyContinue' -or ($PSBoundParameters.ContainsKey('Verbose') -and $PSBoundParameters['Verbose'])
    }

    process
    {
        $aptCacheParams = @('show')

        if ($PSBoundParameters.ContainsKey('Name'))
        {
            $Name.ForEach({
                if ($_ -cmatch '[A-Z]')
                {
                    Write-Warning -Message "Please keep in mind the package name is case sensitive ('$_')."
                }

                if ($PSBoundParameters.Keys -notcontains 'Version')
                {
                    $aptCacheParams += $_
                }
                else
                {
                    $aptCacheParams += ('{0}={1}' -f $_, $Version)
                }
            })
        }

        if (-not $AllVersions.IsPresent)
        {
            $aptCacheParams += '--no-all-versions'
        }
        elseif ($PSBoundParameters.Keys -contains 'Version')
        {
            Write-Debug -Message "Searching specific version of packages."
        }
        else
        {
            $aptCacheParams += '--all-versions'
        }

        $aptCacheParams += '-q' #quiet with no progress bars
        $outputFromCurrentObject = @()
        Invoke-NativeCommand -Executable 'apt-cache' -Parameters $aptCacheParams -Verbose:$verbose | ForEach-Object -Process {
            if (-not [string]::IsNullOrEmpty($_))
            {
                Write-Debug -Message "Adding > $_"
                $outputFromCurrentObject += $_
            }
            else
            {
                [nxAptPackage]($outputFromCurrentObject | Get-PropertyHashFromListOutput -AddExtraPropertiesAsKey AdditionalFields -AllowedPropertyName ([nxAptPackage].GetProperties().Name))
                Write-Verbose -Message "Cleaning up `$outputFromCurrentObject."
                $outputFromCurrentObject = @()
            }
        } -End {
            if ($outputFromCurrentObject.Count -gt 0)
            {
                [nxAptPackage]($outputFromCurrentObject | Get-PropertyHashFromListOutput -AddExtraPropertiesAsKey AdditionalFields -AllowedPropertyName ([nxAptPackage].GetProperties().Name))
            }
        }
    }
}
