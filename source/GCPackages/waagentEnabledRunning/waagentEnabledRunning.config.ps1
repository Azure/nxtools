
configuration waagentEnabledRunning {
    Import-DscResource -ModuleName nxtools

    node waagentEnabledRunning {
        nxService waagentConfig {
            Name    = 'waagent.service'
            State   = 'running'
            Enabled = $true
        }
    }
}
