class ValidShell : System.Management.Automation.IValidateSetValuesGenerator
{
    [String[]] GetValidValues()
    {
        return (Get-Content -Path '/etc/shells' -ErrorAction 'Stop' | Where-Object -FilterScript {$_ -notmatch '^#'})
    }
}
