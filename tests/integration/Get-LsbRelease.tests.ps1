Describe 'Get-LsbRelease function' -skip:($IsWindows -or $IsMacOS) {
    it 'should not throw (if the binary is installed)' {
     {Get-LsbRelease} | Should -not -Throw
    }
}
