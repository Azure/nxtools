configuration LinuxLogAnalyticsAgentConnection {
    Import-DscResource -ModuleName nxtools

    node LinuxLogAnalyticsAgentConnection {
        GC_LinuxLogAnalyticsAgent LogAnalyticsAgent {
            WorkspaceId =  'NotSpecified'
        }
    }
}
