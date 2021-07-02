# author: Michael Greene

# control 'msid12.1' do
#   impact 1.0
#   title '/etc/passwd file permissions should be 0644'
#   desc 'An attacker could modify userIDs and login shells'

#   describe file('/etc/passwd') do
#     its('mode') { should cmp '0644' }
#   end
# end

# instance of MSFT_ChefInSpecResource as $MSFT_ChefInSpecResource2ref
# {
#     ResourceID = "[ChefInSpec]MSID121";
#     SourceInfo = "::11::5::ChefInSpec";
#     Name = "PasswordPolicy_msid121";
#     ModuleName = "ChefInSpec";
#     ModuleVersion = "1.0";
#     GithubPath = "PasswordPolicy_msid121/Modules/PasswordPolicy_msid121_inspec_controls/";
#     ConfigurationName = "chefInSpec";
# };


[DscResource()]
class GC_msid121
{
    [DscProperty(Key)]
    [String] $Name

    [DscProperty(NotConfigurable)]
    [Reason[]] $Reasons

    [GC_msid121] Get()
    {
        $etcPasswdFile = Get-nxItem -Path '/etc/passwd'
        $modeDifference = Compare-nxMode -ReferenceMode 0644 -DifferenceMode $etcPasswdFile.Mode

        $result = [GC_msid121]::new()
        $result.Name = $this.Name

        if ($null -ne $modeDifference)
        {
            $result.Reasons += [Reason]@{
                Code = '{0}:{0}:passwd' -f $this.GetType()
                Phrase = 'The file ''/etc/passwd'' has a mode of ''{0}''.' -f $etcPasswdFile.Mode.ToOctal()
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
