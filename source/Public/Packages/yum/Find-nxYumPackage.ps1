function Find-nxYumPackage
{
    [CmdletBinding()]
    [OutputType([nxAptPackage])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        # Name of the Package fo find in the Cached list of packages. Make sure you update the cache as needed.
        $Name,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        # Specifc Version of a package that you want to find in the Cached list of packages.
        $Version,

        [Parameter()]
        [switch]
        # Show all versions available for a package.
        $AllVersions
    )

    begin
    {
        $verbose = $VerbosePreference -ne 'SilentlyContinue' -or ($PSBoundParameters.ContainsKey('Verbose') -and $PSBoundParameters['Verbose'])
    }

    process
    {
        $yumInfoParams = @('info','-q')

        if ($AllVersions.IsPresent -or $PSBoundParameters.ContainsKey('Version'))
        {
            $yumInfoParams += '--show-duplicates'
        }

        if ($PSBoundParameters.ContainsKey('Name'))
        {
            $Name.ForEach({
                $yumInfoParams += $_
            })
        }

        $outputFromCurrentObject = @()
        Invoke-NativeCommand -Executable 'yum' -Parameters $yumInfoParams -Verbose:$verbose | ForEach-Object -Process {
            if (-not [string]::IsNullOrEmpty($_))
            {
                Write-Debug -Message "Adding > $_"
                $outputFromCurrentObject += $_
            }
            else
            {
                [nxYumPackage]($outputFromCurrentObject | Get-PropertyHashFromListOutput -Regex '^\s*(?<property>[\w][\w-\s]*):\s*(?<val>.*)' -AddExtraPropertiesAsKey AdditionalFields -AllowedPropertyName ([nxYumPackage].GetProperties().Name))
                Write-Verbose -Message "Cleaning up `$outputFromCurrentObject."
                $outputFromCurrentObject = @()
            }
        } -End {
            if ($outputFromCurrentObject.Count -gt 0)
            {
                [nxYumPackage]($outputFromCurrentObject | Get-PropertyHashFromListOutput -Regex '^\s*(?<property>[\w][\w-\s]*):\s*(?<val>.*)' -AddExtraPropertiesAsKey AdditionalFields -AllowedPropertyName ([nxYumPackage].GetProperties().Name))
            }
        } |
        Where-Object -FilterScript { # return specific version if $Version is set
            if ($_.repo -eq 'installed')
            {
                $false
            }
            elseif (-not $PSBoundParameters.ContainsKey('Version'))
            {
                $true
            }
            elseif ($PSBoundParameters.ContainsKey('Version') -and $_.Version -Like $Version)
            {
                $true
            }
            else
            {
                $false
            }
        }
    }
}
