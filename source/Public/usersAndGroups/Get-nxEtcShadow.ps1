function Get-nxEtcShadow
{
    [CmdletBinding(DefaultParameterSetName = 'byUserName')]
    [outputType([nxEtcShadowEntry])]
    param
    (
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'byUserName', Position = 0)]
        [System.String[]]
        [Alias('GroupMember')]
        $UserName,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'byRegexPattern', Position = 0)]
        [regex]
        $Pattern
    )

    begin
    {
        $readEtcShadow = {
            Get-Content -Path '/etc/shadow' | ForEach-Object -Process {
                [nxEtcShadowEntry]$_
            }
        }
    }

    process
    {
        if ($PSCmdlet.ParameterSetName -eq 'byUserName' -and -not $PSBoundParameters.ContainsKey('UserName'))
        {
            Write-Debug -Message "[Get-nxEtcShadowEntry] Reading /etc/shadow without filter."
            &$readEtcShadow
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'byRegexPattern')
        {
            Write-Debug -Message "[Get-nxEtcShadowEntry] Matching 'UserName' with regex pattern '$Pattern'."
            &$readEtcShadow | Where-Object -FilterScript {
                $_.username -match $Pattern
            }
        }
        else
        {
            $allUsers = &$readEtcShadow
            foreach ($userNameEntry in $UserName)
            {
                Write-Debug -Message "[Get-nxEtcShadowEntry] Finding Local users by UserName '$userNameEntry'."
                $allUsers | Where-Object -FilterScript {
                    $_.username -eq $userNameEntry
                }
            }
        }
    }
}
