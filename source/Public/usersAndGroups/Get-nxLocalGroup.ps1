function Get-nxLocalGroup
{
    [CmdletBinding(DefaultParameterSetName = 'byGroupName')]
    [OutputType()]
    param
    (
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'byGroupName', Position = 0)]
        [System.String[]]
        [Alias('Group')]
        $GroupName,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'byRegexPattern', Position = 0)]
        [regex]
        $Pattern
    )

    begin
    {
        # by doing this, we prefer content accuracy than IO/Speed (the /etc/group may be read many times).
        $readEtcGroupCmd = {
            Get-Content -Path '/etc/group' | ForEach-Object -Process {
                [nxLocalGroup]$_
            }
        }
    }

    process
    {
        if ($PSCmdlet.ParameterSetName -eq 'byGroupName' -and -not $PSBoundParameters.ContainsKey('GroupName'))
        {
            Write-Debug -Message "[Get-nxLocalGroup] Reading /etc/group without filter."
            &$readEtcGroupCmd
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'byRegexPattern')
        {
            Write-Debug -Message "[Get-nxLocalGroup] Matching 'GroupName' with regex pattern '$Pattern'."
            &$readEtcGroupCmd | Where-Object -FilterScript {
                $_.GroupName -match $Pattern
            }
        }
        else
        {
            $allGroups = &$readEtcGroupCmd
            foreach ($GroupNameEntry in $GroupName)
            {
                Write-Debug -Message "[Get-nxLocalGroup] Finding Local group by GroupName '$GroupNameEntry'."
                $allGroups | Where-Object -FilterScript {
                    $_.Groupname -eq $GroupNameEntry
                }
            }
        }
    }
}
