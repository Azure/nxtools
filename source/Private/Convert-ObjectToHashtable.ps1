
function Convert-ObjectToHashtable
{
    [CmdletBinding()]
    [OutputType([Hashtable])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [object]
        [Alias('Object')]
        $InputObject
    )

    process
    {

        $hashResult = @{}

        $InputObject.psobject.Properties | Foreach-Object {
            $hashResult[$_.Name] = $_.Value
        }

        return $hashResult
    }
}
