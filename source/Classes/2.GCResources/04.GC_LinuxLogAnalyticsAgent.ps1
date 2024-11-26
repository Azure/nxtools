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

        $linuxApplicationResource = [GC_InstalledApplicationLinux]@{
            Name = $this.WorkspaceId
            AttributesYmlContent = $this.AttributesYmlContent
        }

        if ($linuxApplicationResource.Test())
        {
            if ($this.WorkspaceId -ieq "NotSpecified")
            {
                $this.Reasons += [Reason]@{
                    code = 'LogAnalyticsAgent:LogAnalyticsAgent:ApplicationInstalled'
                    phrase = 'The Log Analytics agent application is installed.'
                }
            }
            else {
                $this.TestConnectionStatus()
            }
        }
        else
        {
            $this.Reasons += [Reason]@{
                code = 'LogAnalyticsAgent:LogAnalyticsAgent:ApplicationNotInstalled'
                phrase = 'The Log Analytics agent application is not installed.'
            }
        }

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

        if ($this.WorkspaceId -ieq "NotSpecified")
        {
            return $true
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

        $reasonCodePrefix = 'LogAnalyticsAgent:LogAnalyticsAgent'
        $ComplianceStatus = $false
        if ($connectedWorkspaceIds.Count -eq 0)
        {
            $this.Reasons += [Reason]@{
                code = $reasonCodePrefix + ':WorkspaceNotFound'
                phrase = 'The Log Analytics agent application is not connected to any workspace.'
            }
        }
        else
        {
            $ComplianceStatus = $true
            $notConnectedWorkspaceIds = @()
            if (-not($this.WorkspaceId -ieq "NotSpecified"))
            {
                $workspaceIdList = @($this.WorkspaceId.Split(';').Trim())
                $workspaceIdList = $workspaceIdList.ToLower()
                $connectedWorkspaceIds = $connectedWorkspaceIds.ToLower()
                foreach ($individualWorkspaceId in $workspaceIdList)
                {
                    if (-not($connectedWorkspaceIds -match $individualWorkspaceId))
                    {
                        $ComplianceStatus = $false
                        $notConnectedWorkspaceIds = $notConnectedWorkspaceIds + $individualWorkspaceId
                    }
                }
            }

            if ($ComplianceStatus)
            {
                $this.Reasons += [Reason]@{
                    code = $reasonCodePrefix + ':ConnectedWorkspaces'
                    phrase = "{0}" -f ($connectedWorkspaceIds -join ';')
                }
            }
            else
            {
                $this.Reasons += [Reason]@{
                    code = $reasonCodePrefix + ':WorkspaceNotFound'
                    phrase = 'Could not find a workspace with the specified workspace ID ''{0}'' connected to this machine.' -f ($notConnectedWorkspaceIds -join ';')
                }
            }
        }

        return $ComplianceStatus
    }
}
