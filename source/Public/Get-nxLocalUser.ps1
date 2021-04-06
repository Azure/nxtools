function Get-nxLocalUser
{
    [CmdletBinding(DefaultParameterSetName = 'byRegexPattern')]
    [OutputType()]
    param
    (
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'byUserName')]
        [System.String[]]
        [Alias('GroupMember')]
        $UserName,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'byRegexPattern')]
        [regex]
        $Pattern
    )

    begin
    {
        $readPasswdCmd = {
            Get-Content -Path '/etc/passwd' | ForEach-Object -Process {
                [nxLocalUser]$_
            }
        }
    }

    process
    {
        if ($PSCmdlet.ParameterSetName -ne 'byUserName' -and $PSCmdlet.ParameterSetName -eq 'byRegexPattern' -and -not $PSBoundParameters.ContainsKey('Pattern'))
        {
            &$readPasswdCmd
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'byRegexPattern')
        {
            &$readPasswdCmd | Where-Object -FilterScript {
                $_.username -match $Pattern
            }
        }
        else
        {
            foreach ($userNameEntry in $UserName)
            {
                &$readPasswdCmd | Where-Object -FilterScript {
                    $_.username -eq $userNameEntry
                }
            }
        }
    }
}
