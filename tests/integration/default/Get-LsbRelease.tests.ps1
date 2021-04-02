Describe 'Get-LsbRelease function' {
    it 'should not throw (if the binary is installed)' {
     {Get-LsbRelease} | Should -not -Throw
    }
}
