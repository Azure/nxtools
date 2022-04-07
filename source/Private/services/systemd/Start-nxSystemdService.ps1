function Start-nxSystemdService
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
            Write-Verbose -Message ('Starting service ''{0}''.' -f $serviceName)
            Invoke-NativeCommand -Executable 'systemctl' -Parameters @('start',$serviceName) | ForEach-Object -Process {
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
