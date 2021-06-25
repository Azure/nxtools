function Get-nxDistributionInfo
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.String[]]
        $InfoFilePath = '/etc/*-release'
    )

    $verbose = ($PSBoundParameters.ContainsKey('Verbose') -and $PSBoundParameters.Verbose) -or $VerbosePreference -ne 'SilentlyContinue'

    $InfoFilePath = [string[]](Get-Item $InfoFilePath -ErrorAction Stop -Verbose:$Verbose)
    Write-Verbose -Message "Extracting distro info from '$($InfoFilePath -join "', '")'"

    $properties = Get-Content -Path $InfoFilePath |
        Get-PropertyHashFromListOutput -Regex '^\s*(?<property>[\w-\s]*)=\s*"?(?<val>.*)\b'

    [PSCustomObject]$properties | Add-Member -TypeName 'nx.DistributionInfo' -PassThru
}
