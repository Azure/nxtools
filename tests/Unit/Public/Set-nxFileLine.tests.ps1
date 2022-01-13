Describe 'Set-nxFileLine function' -Skip {
    it 'should not throw' {
        #gc $PSScriptRoot/assets/test.txt | % { $_ -replace '^pretty\s(?<adj>easy)','very ${adj}'} | Set-Content -Path $PSScriptRoot/assets/test.txt
    }
}
