
# author: Michael Greene

# control 'msid110' do
#   impact 1.0
#   title 'Remote connections from accounts with empty passwords should be disabled.'
#   desc 'An attacker could gain access through password guessing'

#   describe file('/etc/ssh/sshd_config') do
#     its('content') { should match "^[\s\t]*PermitEmptyPasswords\s+no" }
#   end
# end

# instance of MSFT_ChefInSpecResource as $MSFT_ChefInSpecResource2ref
# {
#     ResourceID = "[ChefInSpec]MSID110";
#     SourceInfo = "::11::5::ChefInSpec";
#     Name = "PasswordPolicy_msid110";
#     ModuleName = "ChefInSpec";
#     ModuleVersion = "1.0";
#     GithubPath = "PasswordPolicy_msid110/Modules/PasswordPolicy_msid110_inspec_controls/";
#     ConfigurationName = "chefInSpec";
# };



[DscResource()]
class GC_msid110
{
    [DscProperty(Key)]
    [String] $Name

    [DscProperty(NotConfigurable)]
    [Reason[]] $Reasons

    [GC_msid110] Get()
    {
        $sshdContentMatch = Get-Content -Path '/etc/ssh/sshd_config' -ErrorAction SilentlyContinue | Where-Object -FilterScript {
            $_ -match '^[\s\t]*PermitEmptyPasswords\s+no'
        }

        $result = [GC_msid110]::new()
        $result.Name = $this.Name

        if (-not $sshdContentMatch)
        {
            $result.Reasons += [Reason]@{
                Code = '{0}:{0}:sshdPermitEmptyPasswords' -f $this.GetType()
                Phrase = 'Remote connections from accounts with empty passwords is not disabled.'
            }
        }

        return $result
    }

    [bool] Test()
    {
        $getResult = $this.Get()
        if ($getResult.Reasons -is [Reason[]] -and $getResult.Count -ge 1)
        {
            return $false
        }
        else
        {
            return $true
        }
    }

    [void] Set()
    {
        throw 'The Set method is not implemented for this Audit resource.'
    }
}
