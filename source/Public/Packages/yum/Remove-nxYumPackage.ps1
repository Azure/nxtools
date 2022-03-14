function Remove-nxYumPackage
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
        $Version
    )

    begin
    {
        $verbose = $VerbosePreference -ne 'SilentlyContinue' -or ($PSBoundParameters.ContainsKey('Verbose') -and $PSBoundParameters['Verbose'])
    }

    process
    {
        # yum remove
        $yumGetRemoveParams = @('remove','-q','-y')

        $packageToRemove = $Name
        if ($PSBoundParameters.ContainsKey('Version'))
        {
            Write-Verbose -Message "Trying to remove package '$Name' at the specified version '$Version'."
            # Overriding $packageToRemove with specified version
            $packageToRemove = $Name.ForEach({'{0}-{1}' -f $_, $Version})
        }

        Invoke-NativeCommand -Executable 'yum' -Parameters @($yumGetRemoveParams+$packageToRemove) -Verbose:$verbose |
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
