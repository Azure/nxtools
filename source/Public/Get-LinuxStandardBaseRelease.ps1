# By default on Debian 10, lsb-release package is not installed, so lsb_release
# gives a command not found.
function Get-LinuxStandardBaseRelease
{
    [OutputType([PSCustomObject])]
    [CmdletBinding()]
    param
    (
    )

    if ($PSBoundParameters.Verbose -or $VerbosePreference -ne 'SilentlyContinue')
    {
        $Verbose = $true
    }
    else
    {
        $Verbose = $false
    }

    $properties = Invoke-NativeCommand -Executable 'lsb_release' -Parameters '--all' -Verbose:$Verbose |
        Get-PropertyHashFromListOutput -ErrorHandling {
            switch -Regex ($_)
            {
                ''                 { }
                'No\sLSB\smodules' { Write-Verbose $_ }
                Default            { Write-Error "$_" }
            }
        }

    [PSCustomObject]$properties | Add-Member -TypeName 'Package.LsbRelease' -PassThru
}

Set-Alias -Name Get-LsbRelease -Value Get-LinuxStandardBaseRelease
