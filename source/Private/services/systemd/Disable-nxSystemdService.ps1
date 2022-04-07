function Disable-nxSystemdService
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
            Write-Verbose -Message ('Disabling service ''{0}''.' -f $serviceName)
            Invoke-NativeCommand -Executable 'systemctl' -Parameters @('disable',$serviceName) | ForEach-Object -Process {
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
