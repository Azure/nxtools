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
    [bool] $ComplianceStatus = $false

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
        $this.Reasons += $linuxApplicationGetResult.Reasons

        # get the information about connected workspace IDs
        $this.TestConnectionStatus()
        $getResult.Reasons = $this.Reasons

        return $getResult
    }

    [bool] Test()
    {
        $linuxApplicationResource = [GC_InstalledApplicationLinux]@{
            Name = $this.WorkspaceId
            AttributesYmlContent = $this.AttributesYmlContent
        }

        if (-not ($linuxApplicationResource.Test()))
        {
            return $false
        }

        return $this.TestConnectionStatus()
    }

    [void] Set()
    {
        throw "Remediation (Set) is not implemented."
    }

    [bool] TestConnectionStatus()
    {
        $workspaceDir = Get-ChildItem '/etc/opt/microsoft/omsagent' -ErrorAction SilentlyContinue
        $connectedWorkspaceIds = @()
        $workspaceDir | ForEach-Object { if (($_.Name -match '(?im)^[{(]?[0-9A-F]{8}[-]?(?:[0-9A-F]{4}[-]?){3}[0-9A-F]{12}[)}]?$')) { $connectedWorkspaceIds = $connectedWorkspaceIds + $_.Name } }

        $reasonCodePrefix = 'LogAnalyticsAgent_'
        if ($connectedWorkspaceIds.Count -eq 0)
        {
            $this.ComplianceStatus = $false
            $this.Reasons += [Reason]@{
                code = $reasonCodePrefix + 'NotConnected'
                phrase = 'The Log Analytics agent is not connected to any Workspace.'
            }
        }
        else
        {
            $this.ComplianceStatus = $true
            $notConnectedWorkspaceIds = @()
            if ($this.WorkspaceId -ne "NotSpecified")
            {
                $workspaceIdList = @($this.WorkspaceId.Split(';').Trim())
                $workspaceIdList = $workspaceIdList.ToLower()
                $connectedWorkspaceIds = $connectedWorkspaceIds.ToLower()
                foreach ($individualWorkspaceId in $workspaceIdList)
                {
                    if (-not($connectedWorkspaceIds -match $individualWorkspaceId))
                    {
                        $this.ComplianceStatus = $false
                        $notConnectedWorkspaceIds = $notConnectedWorkspaceIds + $individualWorkspaceId
                    }
                }
            }

            if ($this.ComplianceStatus)
            {
                $this.Reasons += [Reason]@{
                    code = $reasonCodePrefix + 'WorkspaceID'
                    phrase = 'The Log Analytics agent is connected to ''{0}'' workspaces.' -f ($connectedWorkspaceIds -join ';')
                }
            }
            else
            {
                $this.Reasons += [Reason]@{
                    code = $reasonCodePrefix + 'WorkspaceID'
                    phrase = 'The Log Analytics agent is not connected to ''{0}'' workspaces.' -f ($notConnectedWorkspaceIds -join ';')
                }
            }
        }

        return $this.ComplianceStatus
    }
}
