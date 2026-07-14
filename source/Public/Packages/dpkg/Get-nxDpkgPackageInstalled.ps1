function Get-nxDpkgPackageInstalled
{
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 0)]
        [Alias('Package')]
        [string[]]
        $Name
    )

    process
    {
        # Debian policy says Package name must be lowercase, making the user a service by forcing ToLower()
        # https://www.debian.org/doc/debian-policy/ch-controlfields.html#s-f-source
        $Name = $Name.ForEach({$_.ToLower()})

        Invoke-NativeCommand -Executable 'dpkg-query' -Parameters @('-W',($Name -join ' ')) |
            ForEach-Object -Process {
                if ($_ -is [System.Management.Automation.ErrorRecord])
                {
                    switch -Regex ($_)
                    {
                        # this Adds a way to process the error stream in a customized way.
                        # 'no\spackages\sfound' { throw "Package $($Name) not found." } # Use this if you wan to throw when this error is raised
                        default { Write-Error "$_." }
                    }
                }
                else
                {
                    $dpkgPackage = $_ -split "`t"
                    [PSCustomObject]@{
                        PSTypeName  = 'nxDpkgPackage.Installed'
                        Name        = $dpkgPackage[0]
                        Version     = $dpkgPackage[1]
                    }
                }
            }
    }
}
