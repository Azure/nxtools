#!/usr/bin/env pwsh-preview
if ((Get-PSRepository -Name PSGallery).InstallationPolicy -ne 'Trusted')
{
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
}

Install-Module -Name PSDesiredStateConfiguration -Confirm:$false
Import-Module -Name PSDesiredStateConfiguration -PassThru
Enable-ExperimentalFeature -Name PSDesiredStateConfiguration.InvokeDscResource

Install-Module -Name GuestConfiguration -AllowPrerelease
Import-Module -Name GuestConfiguration
Enable-ExperimentalFeature -Name GuestConfiguration.Pester
Enable-ExperimentalFeature -Name GuestConfiguration.SetScenario
