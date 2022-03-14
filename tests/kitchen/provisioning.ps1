#!/usr/bin/env pwsh


$ProgressPreference = 'SilentlyContinue'

if ((Get-PSRepository -Name PSGallery).InstallationPolicy -ne 'Trusted')
{
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
}

Install-Module -Name PSDesiredStateConfiguration -RequiredVersion 2.0.5 -Confirm:$false
Import-Module -Name PSDesiredStateConfiguration -PassThru
Enable-ExperimentalFeature -Name PSDesiredStateConfiguration.InvokeDscResource -Confirm:$false

Install-Module -Name GuestConfiguration -AllowPrerelease
Import-Module -Name GuestConfiguration
