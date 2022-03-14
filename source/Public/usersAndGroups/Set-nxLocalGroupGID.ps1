
function Set-nxLocalGroupGID
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([void])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $GroupName,

        [Parameter(Mandatory = $true)]
        [int]
        [Alias('GID')]
        $GroupID
    )

    $gpasswdParams = @('-g', $GroupID, $GroupName)


    if ($PSCmdlet.ShouldProcess(
                "Performing the unix command 'gpasswd $(($gpasswdParams -join ' '))'.",
                "$GroupName",
                "Setting LocalGroup $GroupName"
            )
        )
    {
        Invoke-NativeCommand -Executable 'groupmod' -Parameters $groupmodParams -Verbose:$verbose |
        Foreach-Object -ScriptBlock {
            throw $_
        }
    }
}
