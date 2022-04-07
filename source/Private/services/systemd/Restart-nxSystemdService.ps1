function Restart-nxSystemdService
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
            Write-Verbose -Message ('Restarting Service ''{0}''.' -f $serviceName)
            Invoke-NativeCommand -Executable 'systemctl' -Parameters @('restart',$serviceName) | ForEach-Object -Process {
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
