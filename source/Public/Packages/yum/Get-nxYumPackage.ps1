function Get-nxYumPackage
{
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [String[]]
        $Name
    )

    process
    {
        $getNxYumPackageInstalledParams = @{ }

        if ($PSBoundParameters.ContainsKey('Name'))
        {
            $getNxYumPackageInstalledParams['Name'] = $Name
            $getNxYumPackageInstalledParams['ErrorAction'] = 'Ignore'
        }

        Get-nxYumPackageInstalled @getNxYumPackageInstalledParams | ForEach-Object -Process {
            $yumInfoParams = @('info','-q', $_.Name)
            $oneObjectOutput = [System.Collections.ArrayList]::new()
            Invoke-NativeCommand -Executable 'yum' -Parameters $yumInfoParams -ErrorAction Ignore |
                Foreach-Object -Process {
                    switch -Regex ($_)
                    {
                        '^Available\sPackages'
                        {
                            Write-Verbose -Message $_
                            break
                        }

                        '^Installed\sPackages'
                        {
                            Write-Verbose -Message $_
                            break
                        }

                        '^$'
                        {
                            Write-Debug -Message "Empty line reached."
                            if ($oneObjectOutput.count -gt 0)
                            {
                                ,$oneObjectOutput.Clone()
                                $oneObjectOutput.Clear()
                            }
                        }

                        default
                        {
                            Write-Debug -Message "Adding line to object: $($_)"
                            $null = $oneObjectOutput.Add($_)
                        }
                    }
                } | ForEach-Object -Process {
                    $getPropertyHashFromListOutputParams = @{
                        AllowedPropertyName     = ([nxYumPackage].GetProperties().Name)
                        # AddExtraPropertiesAsKey = 'AdditionalFields'
                        ErrorVariable           = 'packageError'
                        Regex                   = '^(?<property>[\w][\w-\s]*):\s*(?<val>.*)'
                        DiscardExtraProperties = $true
                    }

                    $properties = $_.GetEnumerator() | Get-PropertyHashFromListOutput @getPropertyHashFromListOutputParams
                    $properties['PackageType'] = 'yum'

                    $properties['Description'] = ($properties['Description'] -split '\n').Foreach({
                        $_ -replace '^\s+\:'
                    }) -join "`n"

                    if (-not $packageError)
                    {
                        [nxYumPackage]$properties
                    }
                }
        }
    }
}
