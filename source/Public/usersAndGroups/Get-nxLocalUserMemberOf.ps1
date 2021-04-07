function Get-nxLocalUserMemberOf
{
    [CmdletBinding()]
    [OutputType([PSCustomObject[]])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [System.String[]]
        [Alias('UserName','UserId')]
        $User
    )

    process {
        foreach ($UserItem in $User)
        {
            [string] $UserName = ''
            if ($UserItem -match '^\d+$')
            {
                # by User ID
                $UserName = Get-nxLocalUser | Where-Object -FilterScript { $_.UserId -eq $UserItem }
            }
            else
            {
                # by User Name
                $UserName = $UserItem
            }

            $memberOf = (Invoke-NativeCommand -Executable 'id' -Parameters @('-G', '-n', $UserName)) -split '\s+' | Foreach-Object -Process {
                if ($_ -match '^id:\s')
                {
                    throw $_
                }
                else
                {
                    Get-nxLocalGroup -GroupName $_
                }
            }

            [PSCustomObject]@{
                PsTypeName = 'nx.LocalUser.MemberOf'
                User       = $UserName
                MemberOf   = $memberOf
            }
        }
    }
}
