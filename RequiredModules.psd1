@{
    PSDependOptions             = @{
        AddToPath  = $true
        Target     = 'output\RequiredModules'
        Parameters = @{
            Repository = 'PSGallery'
        }
    }

    InvokeBuild                 = 'latest'
    PSScriptAnalyzer            = 'latest'
    Pester                      = 'latest'
    Plaster                     = 'latest'
    ModuleBuilder               = 'latest'
    ChangelogManagement         = 'latest'
    Sampler                     = @{
        version = 'latest'
        Parameters = @{
            AllowPrerelease = $true
        }
    }
    'Sampler.GitHubTasks'       = 'latest'
    MarkdownLinkCheck           = 'latest'
    'DscResource.Common'        = 'latest'
    'DscResource.Test'          = @{
        version = 'latest'
        Parameters = @{
            AllowPrerelease = $true
        }
    }
    'DscResource.AnalyzerRules' = 'latest'
    # xDscResourceDesigner        = 'latest'
    'DscResource.DocGenerator'  = 'latest'
    PSNativeCmdDevKit           = 'latest'

    GuestConfiguration          = @{
        version = 'latest'
        Parameters = @{
            AllowPrerelease = $true
        }
    }
}
