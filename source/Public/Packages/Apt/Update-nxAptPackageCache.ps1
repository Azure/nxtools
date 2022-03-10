function Update-nxAptPackageCache
{
    [CmdletBinding()]
    [OutputType([void])]
    param
    (
        # dono
    )

    begin
    {
        $verbose = $VerbosePreference -ne 'SilentlyContinue' -or ($PSBoundParameters.ContainsKey('Verbose') -and $PSBoundParameters['Verbose'])
    }

    process
    {
        # apt-get update
        $aptGetUpdateParams = @('update','--quiet')

        Invoke-NativeCommand -Executable 'apt-get' -Parameters $aptGetUpdateParams -Verbose:$verbose |
        ForEach-Object -Process {
            if ($_ -is [System.Management.Automation.ErrorRecord])
            {
                Write-Error -Message $_
            }
            else
            {
                Write-Verbose -Message ($_+"`r").TrimEnd('\+')
            }
        }
    }
}
