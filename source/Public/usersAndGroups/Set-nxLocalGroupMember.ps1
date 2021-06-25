function Set-nxLocalGroupMember
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '')]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [String[]]
        $Member,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [String]
        $GroupName,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Switch]
        $PassThru
    )

    process
    {
        Set-nxLocalGroup @PSBoundParameters
    }
}
