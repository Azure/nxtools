
[DscResource()]
class nxPackage
{
    [DscProperty()]
    [Ensure] $Ensure = [Ensure]::Present

    [DscProperty(Key)]
    [String] $Name

    [DscProperty()]
    [String] $Version

    [DscProperty()]
    [String] $PackageType

    [DscProperty(NotConfigurable)]
    [Reason[]] $Reasons

    [nxPackage] Get()
    {
        $currentState = [nxPackage]::new()
        $getNxPackageParams = @{
            Name = $this.Name
        }

        $packageFound = Get-nxPackage @getNxPackageParams

        if ($packageFound.count -eq 0)
        {
            $currentState.Ensure = [Ensure]::Absent
        }
        elseif ($packageFound.count -gt 1 -and $packageFound.Where{$_.Version -eq $this.Version})
        {
            $packageFound = ($packageFound.Where{$_.Version -eq $this.Version})[0]
        }
        else
        {
            $packageFound = $packageFound[0]
        }

        $currentState.Name = $this.Name
        $currentState.PackageType = $packageFound.PackageType
        $currentState.Version = $packageFound.Version

        $valuesToCheck = @(
                # UserName can be skipped because it's determined with Ensure absent/present
                'Ensure'
                'Version'
            ).Where({ $null -ne $this.$_ }) #remove properties not set from comparison


        $compareStateParams = @{
            CurrentValues = ($currentState | Convert-ObjectToHashtable)
            DesiredValues = ($this | Convert-ObjectToHashtable)
            ValuesToCheck = $valuesToCheck
        }

        $compareState = Compare-DscParameterState @compareStateParams

        $currentState.reasons = switch ($compareState.Property)
        {
            'Ensure'
            {
                [Reason]@{
                    Code = '{0}:{0}:Ensure' -f 'nxPackage'
                    Phrase ='The {0} is not in desired state because the package was expected {1} but was {2}.' -f $this.GetType(), $this.Ensure, $currentState.Ensure
                }
            }

            'PackageVersion'
            {
                if ($this.Ensure -eq [Ensure]::Present -and $currentState.Ensure -eq [Ensure]::Present)
                {
                    [Reason]@{
                        Code = '{0}:{0}:PackageVersion' -f 'nxPackage'
                        Phrase = 'The Package {0} is present but we''re expecting version {1} and got {2}' -f $this.Name, $this.Version, $currentState.Version
                    }
                }
            }
        }

        return $currentState
    }

    [bool] Test()
    {
        $currentState = $this.Get()
        $testTargetResourceResult = $currentState.Reasons.count -eq 0

        return $testTargetResourceResult
    }

    [void] Set()
    {
        $currentState = $this.Get()

        if ($this.Ensure -eq [Ensure]::Present) # must be present
        {
            if ($currentState.Ensure -eq [Ensure]::Absent) # but is absent
            {
                Write-Verbose -Message (
                    'Installing Package {0}' -f $this.Name
                )
            }
            elseif ($currentState.Reasons.Count -gt 0)
            {
                # Package is present, and there's a reason for non compliance
                # Try installing the correct version
                Write-Verbose -Message (
                    'Installing version {0} of package {1}' -f $this.Version,$this.Name
                )
            }

            # Anyway, whether absent or present at wrong version, we can only try to install at specific version
            $installnxPackageParams = @{
                Name = $this.Name
            }

            if (-not [string]::IsNullOrEmpty)
            {
                $installnxPackageParams['Version'] = $this.Version
            }

            Install-nxPackage @installnxPackageParams
        }
        else # Expected Absent
        {
            if ($currentState.Ensure -eq [Ensure]::Present) # But is Absent
            {
                $removenxPackageParams = @{
                    Name = $this.Name
                }

                if (-not [string]::IsNullOrEmpty($this.Version))
                {
                    $removenxPackageParams['Version'] = $this.Version
                }

                Remove-nxPackage @removenxPackageParams
            }

            # Is absent, all good.
        }
    }
}
