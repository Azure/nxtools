# instance of GC_OmsAgent as $GC_OmsAgent1ref
# {
#  ModuleVersion = "0.0.1";
#  SourceInfo = "::4::5::GC_OmsAgent";
#  ResourceID = "Audit OmsAgent connection";
#  ModuleName = "nxtools";
#  WorkspaceId = "NotSpecified";
#  ConfigurationName = "OmsAgentConnection";
# };

[DscResource()]
class GC_OmsAgent
{
    [DscProperty(Key)]
    [String] $WorkspaceId = "NotSpecified"

    [DscProperty(NotConfigurable)]
    [String] $AttributesYmlContent = "packages: [omsagent]"

    [DscProperty(NotConfigurable)]
    [string[]] $PackageShouldBeInstalled = @()

    [DscProperty(NotConfigurable)]
    [Reason[]] $Reasons

    [GC_OmsAgent] Get()
    {
        $getResult = [GC_OmsAgent]@{
            WorkspaceId = $this.WorkspaceId
        }

        # Get the details about omsagent installation
        $linuxApplicationResource = [GC_InstalledApplicationLinux]@{
            Name = $this.WorkspaceId
            AttributesYmlContent = $this.AttributesYmlContent
        }
        $linuxApplicationGetResult = $linuxApplicationResource.Get()
        $getResult.Reasons += $linuxApplicationGetResult.Reasons

        # get the information about connected workspace IDs
        $workspaceDir = Get-ChildItem '/etc/opt/microsoft/omsagent' -ErrorAction SilentlyContinue
        $workspaceIds = $workspaceDir | % { if(($_.Name -match '(?im)^[{(]?[0-9A-F]{8}[-]?(?:[0-9A-F]{4}[-]?){3}[0-9A-F]{12}[)}]?$')) { $_.Name } }
        if($workspaceIds -ne $null)
        {
            if($workspaceIds.GetType().IsArray)
            {
                $getResult.Reasons += [Reason]@{
                    code = 'ConnectedWorkspaces'
                    phrase = 'OmsAgent is connected to ''{0}'' workspaces.' -f ($workspaceIds -join ';')
                }
            }
            else
            {
                $getResult.Reasons += [Reason]@{
                    code = 'ConnectedWorkspaces'
                    phrase = 'OmsAgent is connected to ''{0}'' workspace.' -f $workspaceIds
                }
            }
        }
        else
        {
            $getResult.Reasons += [Reason]@{
                code = 'ConnectedWorkspaces'
                phrase = 'OmsAgent is not connected to any workspace.'
            }
        }

        return $getResult
    }

    [bool] Test()
    {
        $linuxApplicationResource = [GC_InstalledApplicationLinux]@{
            Name = $this.WorkspaceId
            AttributesYmlContent = $this.AttributesYmlContent
        }

        if(-not ($linuxApplicationResource.Test()))
        {
            return $false
        }

        $workspaceDir = Get-ChildItem '/etc/opt/microsoft/omsagent' -ErrorAction SilentlyContinue
        $workspaceIds = $workspaceDir | % { if(($_.Name -match '(?im)^[{(]?[0-9A-F]{8}[-]?(?:[0-9A-F]{4}[-]?){3}[0-9A-F]{12}[)}]?$')) { $_.Name } }
        return ($workspaceIds -ne $null)
    }

    [void] Set()
    {
        throw "Remediation (Set) is not implemented."
    }
}
