function Get-nxSystemdService
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [string[]]
        [Alias('Unit')]
        $Name
    )

    if (-not (Get-Command -Name 'systemctl' -ErrorAction SilentlyContinue))
    {
        throw 'systemctl not found'
    }

    $systemctlParams = @('--type=service', '--no-legend', '--all', '--no-pager')
    if ($PSBoundParameters.ContainsKey('Name'))
    {
        # Because systemctl version 219 and below do not support short name (i.e. centos 7.5)
        $Name = $Name.Foreach{
            if ($_ -notmatch '\.service')
            {
                '{0}.service' -f $_
            }
            else
            {
                $_
            }
        }

        $systemctlParams = $systemctlParams + $Name
    }

    Invoke-NativeCommand -Executable 'systemctl' -Parameters (@('list-units') + $systemctlParams) | ForEach-Object -Process {
        if ($_ -is [System.Management.Automation.ErrorRecord])
        {
            Write-Error -Message $_
        }
        else
        {
            $id, $Load, $Active, $Status, $Description = $_ -split '\s+',5
            $State = if ($Active -eq 'Active')
            {
                [nxServiceState]::Running
            }
            else
            {
                [nxServiceState]::Stopped
            }

            $service = [nxSystemdService]@{
                name        = $id
                Load        = $Load
                Active      = $Active
                State       = $State
                Status      = $status
                Description = $Description
            }

            $null = $service.IsEnabled() # runs the systemctl is-enabled and update the property
            return $service
        }
    }
}
