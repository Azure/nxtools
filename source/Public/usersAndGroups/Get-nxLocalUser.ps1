function Get-nxLocalUser
{
    [CmdletBinding(DefaultParameterSetName = 'byUserName')]
    [OutputType()]
    param
    (
        [Parameter(ValueFromPipelineByPropertyName = $true, ValueFromPipeline = $true, ParameterSetName = 'byUserName', Position = 0)]
        [System.String[]]
        [Alias('GroupMember')]
        $UserName,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'byRegexPattern', Position = 0)]
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
        if ($PSCmdlet.ParameterSetName -eq 'byUserName' -and -not $PSBoundParameters.ContainsKey('UserName'))
        {
            Write-Debug -Message "[Get-nxLocalUser] Reading /etc/passwd without filter."
            &$readPasswdCmd
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'byRegexPattern')
        {
            Write-Debug -Message "[Get-nxLocalUser] Matching 'UserName' with regex pattern '$Pattern'."
            &$readPasswdCmd | Where-Object -FilterScript {
                $_.username -match $Pattern
            }
        }
        else
        {
            $allUsers = &$readPasswdCmd
            foreach ($userNameEntry in $UserName)
            {
                Write-Debug -Message "[Get-nxLocalUser] Finding Local users by UserName '$userNameEntry'."
                $allUsers | Where-Object -FilterScript {
                    $_.username -eq $userNameEntry
                }
            }
        }
    }
}
