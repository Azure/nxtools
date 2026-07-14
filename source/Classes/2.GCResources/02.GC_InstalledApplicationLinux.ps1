# val_packages = attribute('packages', description: 'The names of the packages that should be installed.')

# control 'Installed Application Packages' do
#   impact 1.0
#   title 'Verify installed applications'
#   desc 'Validates that application packages are installed'

#   val_packages.each do |val_package|
#     describe package(val_package) do
#         it { should be_installed }
#     end
#   end
# end

# instance of MSFT_ChefInSpecResource as $MSFT_ChefInSpecResource1ref
# {
#     ResourceID = "[ChefInSpec]InstalledApplicationLinuxResource1";
#     SourceInfo = "::11::5::ChefInSpec";
#     Name = "installed_application_linux";
#     ModuleName = "ChefInSpec";
#     ModuleVersion = "1.0";
#     ConfigurationName = "InstalledApplicationLinux";
#     GithubPath = "installed_application_linux/Modules/installed_application_linux_inspec_controls/";
#     AttributesYmlContent = "packages: [Unknown Application]";
# };

[DscResource()]
class GC_InstalledApplicationLinux
{
    [DscProperty(Key)]
    [String] $Name

    [DscProperty()]
    [String] $AttributesYmlContent = "packages: [Unknown Application]"

    [DscProperty(NotConfigurable)]
    [string[]] $PackageShouldBeInstalled = @()

    [DscProperty(NotConfigurable)]
    [Reason[]] $Reasons

    [GC_InstalledApplicationLinux] Get()
    {
        $getResult = [GC_InstalledApplicationLinux]@{
            Name = $this.Name
        }

        try
        {
            $this.ConvertAttributesYmlContentToStringArray()
        }
        catch
        {
            # An invalid package name is a control-plane misconfiguration. Report it as a
            # non-compliant reason (surfacing the validation message) instead of throwing,
            # so policy gets a clear reason. The invalid name is never evaluated because
            # validation happens before it is passed to the package manager.
            $getResult.Reasons += [Reason]@{
                code = '{0}:{0}:Ensure' -f $this.GetType()
                phrase = $_.Exception.Message
            }

            return $getResult
        }

        $getResult.PackageShouldBeInstalled = (Get-nxPackageInstalled -Name $this.PackageShouldBeInstalled -ErrorAction Ignore).Name
        $this.PackageShouldBeInstalled.Where({$_ -notin $getResult.PackageShouldBeInstalled}).Foreach({
            $getResult.Reasons += [Reason]@{
                code = '{0}:{0}:Ensure' -f $this.GetType()
                phrase = 'The package ''{0}'' is expected to be installed but could not be found on the local system' -f $_
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
        # update $this.PackageShouldBeInstalled
        $stringList = $this.AttributesYmlContent -replace '^packages:\s*\[|^\[|\]$'
        $packageNames = $stringList -split '\s*;\s*'

        # The attribute content is externally supplied; validate it before it is
        # used so a crafted package name cannot be interpreted as anything other
        # than a package identifier downstream.
        Assert-nxValidPackageName -Name $packageNames

        $this.PackageShouldBeInstalled = $packageNames
    }

    [void] ConvertStringArrayToAttributeYmlContent()
    {
        $this.AttributesYmlContent = $this.PackageShouldBeInstalled -join ';'
    }
}
