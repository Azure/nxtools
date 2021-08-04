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
class GC_LinuxLogAnalyticsAgent
{
    [DscProperty(Key)]
    [String] $WorkspaceId = "NotSpecified"

    [DscProperty(NotConfigurable)]
    [String] $AttributesYmlContent = "packages: [omsagent]"

    [DscProperty(NotConfigurable)]
    [string[]] $PackageShouldBeInstalled = @()

    [DscProperty(NotConfigurable)]
    [Reason[]] $Reasons

    [GC_LinuxLogAnalyticsAgent] Get()
    {
        $getResult = [GC_LinuxLogAnalyticsAgent]@{
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
        $workspaceIds = $this.GetConnectedWorkpsaceId()
        $reasonCodePrefix = 'LogAnalyticsAgent_'
        if($workspaceIds -ne $null)
        {
            if($workspaceIds.GetType().IsArray)
            {
                $getResult.Reasons += [Reason]@{
                    code = $reasonCodePrefix + 'WorkspaceID'
                    phrase = 'The Log Analytics agent is connected to ''{0}'' workspaces.' -f ($workspaceIds -join ';')
                }
            }
            else
            {
                $getResult.Reasons += [Reason]@{
                    code = $reasonCodePrefix + 'WorkspaceID'
                    phrase = 'The Log Analytics agent is connected to ''{0}'' workspace.' -f $workspaceIds
                }
            }
        }
        else
        {
            $getResult.Reasons += [Reason]@{
                code = $reasonCodePrefix + 'NotConnected'
                phrase = 'The Log Analytics agent is not connected.'
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

        $workspaceIds = $this.GetConnectedWorkpsaceId()
        return ($workspaceIds -ne $null)
    }

    [void] Set()
    {
        throw "Remediation (Set) is not implemented."
    }

    [string] GetConnectedWorkpsaceId()
    {
        $workspaceDir = Get-ChildItem '/etc/opt/microsoft/omsagent' -ErrorAction SilentlyContinue
        $workspaceIds = $workspaceDir | % { if(($_.Name -match '(?im)^[{(]?[0-9A-F]{8}[-]?(?:[0-9A-F]{4}[-]?){3}[0-9A-F]{12}[)}]?$')) { $_.Name } }
        return $workspaceIds
    }
}
