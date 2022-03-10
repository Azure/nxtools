BeforeAll {
    $ModulePath = (Join-Path -Path '/tmp/verifier' -ChildPath 'modules')
    $testFilePath = '/tmp/verifier/testFile'
}

Describe 'Test [nxFileLine] DSC Resource' {
    it 'Test the File created from template' {
        # [nxFile]@{
        #     FilePath = '/tmp/verifier/testFile'
        # }
    }
}
