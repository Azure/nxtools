# val_packages = attribute('packages', description: 'The names of the packages that should not be installed.')

# control 'Not Installed Application Packages' do
#   impact 1.0
#   title 'Verify not installed applications'
#   desc 'Validates that application packages are not installed'

#   val_packages.each do |val_package|
#     describe package(val_package) do
#         it { should_not be_installed }
#     end
#   end
# end


# instance of MSFT_ChefInSpecResource as $MSFT_ChefInSpecResource1ref
# {
#     ResourceID = "[ChefInSpec]NotInstalledApplicationLinuxResource1";
#     SourceInfo = "::11::5::ChefInSpec";
#     Name = "not_installed_application_linux";
#     ModuleName = "ChefInSpec";
#     ModuleVersion = "1.0";
#     ConfigurationName = "NotInstalledApplicationLinux";
#     GithubPath = "not_installed_application_linux/Modules/not_installed_application_linux_inspec_controls/";
#     AttributesYmlContent = "packages: [Unknown Application]";
# };

[DscResource()]
class GC_NotInstalledApplicationLinux
{
    [DscProperty(Key)]
    [String] $Name

    [DscProperty()]
    [String] $AttributesYmlContent = "packages: [Unknown Application]"

    [DscProperty(NotConfigurable)]
    [string[]] $PackageShouldNotBeInstalled = @()

    [DscProperty(NotConfigurable)]
    [Reason[]] $Reasons

    [GC_NotInstalledApplicationLinux] Get()
    {
        $this.ConvertAttributesYmlContentToStringArray()

        $getResult = [GC_NotInstalledApplicationLinux]@{
            Name = $this.Name
        }

        $getResult.PackageShouldNotBeInstalled = (Get-nxPackageInstalled -Name $this.PackageShouldNotBeInstalled).Name
        $this.PackageShouldNotBeInstalled.Where({$_ -in $getResult.PackageShouldNotBeInstalled}).Foreach({
            $getResult.Reasons += [Reason]@{
                code = '{0}:{0}:Ensure' -f $this.GetType()
                phrase = 'The package ''{0}'' is expected to not be installed but was found on the local system' -f $_
            }
        })

        $getResult.ConvertStringArrayToAttributeYmlContent()
        return $getResult
    }

    [bool] Test()
    {
        $getResult = $this.Get()
        if ($getResult.Reasons -is [Reason[]] -and $getResult.Count -ge 1)
        {
            return $false
        }
        else
        {
            return $true
        }
    }

    [void] Set()
    {
        throw "Remediation (Set) is not implemented yet."
    }

    [void] ConvertAttributesYmlContentToStringArray()
    {
        # remove 'packages:' from the string
        # split what's in [] with ; separator
        # update $this.PackageShouldNotBeInstalled
        $stringList = $this.AttributesYmlContent -replace '^packages:\s*\[|^\[|\]$'
        $this.PackageShouldNotBeInstalled = $stringList -split '\s*;\s*'
    }

    [void] ConvertStringArrayToAttributeYmlContent()
    {
        $this.AttributesYmlContent = $this.PackageShouldNotBeInstalled -join ';'
    }
}
