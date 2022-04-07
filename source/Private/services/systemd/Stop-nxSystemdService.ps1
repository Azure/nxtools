function Stop-nxSystemdService
{
    [CmdletBinding()]
    [OutputType([void])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string[]]
        $Name
    )

    process
    {
        foreach ($serviceName in $Name)
        {
            Write-Verbose -Message ('Stopping service ''{0}''.' -f $serviceName)
            Invoke-NativeCommand -Executable 'systemctl' -Parameters @('stop',$serviceName) | ForEach-Object -Process {
                if ($_ -is [System.Management.Automation.ErrorRecord])
                {
                    Write-Error -Exception $_
                }
                else
                {
                    Write-Verbose -Message $_
                }
            }

        }
    }
}
