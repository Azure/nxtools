function Assert-nxValidPackageName
{
    <#
    .SYNOPSIS
        Validates that each supplied package name is safe to pass to a native package tool.

    .DESCRIPTION
        Package names handed to the nxtools package functions can originate from
        higher-level, externally supplied input (for example a Guest Configuration
        'packages' attribute). Such input must be treated strictly as data.

        This helper enforces a strict allow-list so that a crafted package name can
        never be interpreted as anything other than a package identifier when it is
        later passed to dpkg/yum (via Invoke-NativeCommand). It throws on any name
        that does not match the allow-list.

    .PARAMETER Name
        One or more package names to validate.

    .EXAMPLE
        Assert-nxValidPackageName -Name 'openssl'

    .EXAMPLE
        Assert-nxValidPackageName -Name @('libssl3', 'libssl:amd64')
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [string[]]
        $Name
    )

    # Linux package names only ever contain letters, digits and the characters
    # '.', '_', '+' and '-'. ':' is additionally allowed for architecture-qualified
    # names such as 'libssl:amd64'.
    $validPackageNamePattern = '^[A-Za-z0-9][A-Za-z0-9._+:-]*$'

    foreach ($packageName in $Name)
    {
        if ([string]::IsNullOrWhiteSpace($packageName) -or ($packageName -notmatch $validPackageNamePattern))
        {
            throw ("Invalid package name '{0}'. Package names may only contain letters, digits, and the characters '.', '_', '+', '-' and ':'." -f $packageName)
        }
    }
}
