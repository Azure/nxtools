function Remove-nxAptPackage
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

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [switch]
        # Uninstall all related packages and configuration files.
        $Purge
    )

    begin
    {
        $verbose = $VerbosePreference -ne 'SilentlyContinue' -or ($PSBoundParameters.ContainsKey('Verbose') -and $PSBoundParameters['Verbose'])
    }

    process
    {
        # apt-get update
        $aptGetRemoveParams = @('remove','--quiet','--yes')
        if ($Purge.IsPresent)
        {
            $aptGetRemoveParams[0] = 'purge'
        }

        $packageToRemove = $Name
        if ($PSBoundParameters.ContainsKey('Version'))
        {
            Write-Verbose -Message "Trying to remove package '$Name' at the specified version '$Version'."
            # Overriding $packageToRemove with specified version
            $packageToRemove = $Name.ForEach({'{0}={1}' -f $_, $Version})
        }

        Invoke-NativeCommand -Executable 'apt-get' -Parameters @($aptGetRemoveParams+$packageToRemove) -Verbose:$verbose |
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
