function Get-nxYumPackageInstalled
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
        $Name = $Name.ForEach({$_.ToLower()})
        $yumParams = @('list','installed',($Name -join ' '),'--quiet')
        Write-Debug -Message "Running shell command: yum $($yumParams -join ' ')"

        Invoke-NativeCommand -Executable 'yum' -Parameters $yumParams -ErrorAction SilentlyContinue |
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
                    switch -Regex ($_)
                    {
                        '^Installed\sPackages'
                        {
                            Write-Verbose -Message $_
                            break
                        }

                        default
                        {
                            $yumPackage = $_ -split "\s+"
                            $packageName, $packageArch = $yumPackage[0] -split '\.'

                            [PSCustomObject]@{
                                PSTypeName  = 'nxYumPackage.Installed'
                                Name        = $packageName
                                Arch        = $packageArch
                                Version     = $yumPackage[1]
                                Vendor      = $yumPackage[2]
                            }
                        }
                    }
                }
            }
    }
}
