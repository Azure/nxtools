configuration OmsAgentConnection {
    Import-DscResource -ModuleName nxtools -ModuleVersion 0.3.0

    node OmsAgentConnection {
        GC_OmsAgent omsagentState {
            WorkspaceId =  'NotSpecified'
        }
    }
}
