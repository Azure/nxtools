# By default on Debian 10, lsb-release package is not installed, so lsb_release
# gives a command not found.
function Get-nxLinuxStandardBaseRelease
{
    [OutputType([PSCustomObject])]
    [CmdletBinding()]
    param
    (
    )

    $verbose = ($PSBoundParameters.ContainsKey('Verbose') -and $PSBoundParameters.Verbose) -or $VerbosePreference -ne 'SilentlyContinue'

    $properties = Invoke-NativeCommand -Executable 'lsb_release' -Parameters '--all' -Verbose:$Verbose |
        Get-PropertyHashFromListOutput -ErrorHandling {
            switch -Regex ($_)
            {
                ''                 { }
                'No\sLSB\smodules' { Write-Verbose $_ }
                default            { Write-Error "$_" }
            }
        }

    [PSCustomObject]$properties | Add-Member -TypeName 'nx.LsbRelease' -PassThru
}

Set-Alias -Name Get-LsbRelease -Value Get-nxLinuxStandardBaseRelease
