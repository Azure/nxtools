configuration LinuxLogAnalyticsAgentConnection {
    Import-DscResource -ModuleName nxtools -ModuleVersion 0.3.0

    node LinuxLogAnalyticsAgentConnection {
        GC_LinuxLogAnalyticsAgent LogAnalyticsAgent {
            WorkspaceId =  'NotSpecified'
        }
    }
}
