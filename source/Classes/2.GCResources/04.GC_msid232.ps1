
# author: Michael Greene

# control 'msid23.2' do
#   impact 1.0
#   title 'There are no accounts without passwords'
#   desc 'An attacker could modify userIDs and login shells'

#   describe file('/etc/shadow') do
#     its('content') { should_not match "^[^:]+::" }
#   end
# end

# instance of MSFT_ChefInSpecResource as $MSFT_ChefInSpecResource2ref
# {
#     ResourceID = "[ChefInSpec]MSID232";
#     SourceInfo = "::11::5::ChefInSpec";
#     Name = "PasswordPolicy_msid232";
#     ModuleName = "ChefInSpec";
#     ModuleVersion = "1.0";
#     GithubPath = "PasswordPolicy_msid232/Modules/PasswordPolicy_msid232_inspec_controls/";
#     ConfigurationName = "chefInSpec";
# };

[DscResource()]
class GC_msid232
{
    [DscProperty(Key)]
    [String] $Name

    [DscProperty(NotConfigurable)]
    [Reason[]] $Reasons

    [GC_msid232] Get()
    {
        $userAccountWithoutPassword = Get-nxLocalUser | Where-Object -FilterScript {
            [string]::IsNullOrEmpty($_.etcShadow.Encryptedpassword)
        } #| select username,password,@{N='pass';E={$_.etcShadow.EncryptedPassword}}

        $result = [GC_msid232]::new()
        $result.Name = $this.Name

        foreach ($item in $userAccountWithoutPassword)
        {
            $result.Reasons += [Reason]@{
                Code = '{0}:{0}:{1}' -f $this.GetType(),$item.UserName
                Phrase = 'Username ''{0}'' has an empty password.' -f $item.UserName
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
