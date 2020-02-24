$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Get-DuplicateItem" {

    Context 'Non-terminating errors' {

        $invalidPath =  "TestDrive:\foo"

        It 'Shows error when Path does not exist' {
            Get-DuplicateItem -Path $invalidPath -ErrorVariable err -ErrorAction Continue 2>$null

            $err.Count | Should Not Be 0
        }

        It 'Shows error when LiteralPath does not exist' {
            Get-DuplicateItem -LiteralPath $invalidPath -ErrorVariable err -ErrorAction Continue 2>$null

            $err.Count | Should Not Be 0
        }

        It 'Shows error when pipeline object is not a string' {
            $invalidPathCollection = @( @( "foo", "bar") )
            $invalidPathCollection | Get-DuplicateItem -ErrorVariable err -ErrorAction Continue 2>$null

            $err.Count | Should Not Be 0
        }

        It 'Shows error when pipeline object is not an existing Path' {
            $invalidPath | Get-DuplicateItem -ErrorVariable err -ErrorAction Continue 2>$null

            $err.Count | Should Not Be 0
        }

    }

    Context 'Non-terminating errors' {

        $invalidPath =  "TestDrive:\foo"

        It 'Throws exception when Path does not exist' {
            { Get-DuplicateItem -Path $invalidPath -ErrorAction Stop } | Should Throw
        }

        It 'Throws exception when LiteralPath does not exist' {
            { Get-DuplicateItem -LiteralPath $invalidPath -ErrorAction Stop 2>$null } | Should Throw
        }

        It 'Throws exception when pipeline object is not an existing Path' {
            { $invalidPath | Get-DuplicateItem -ErrorAction Stop 2>$null } | Should Throw
        }

        It 'Throws exception when pipeline object is not a string' {
            $invalidPathCollection = @( @( "foo", "bar") )

            { $invalidPathCollection | Get-DuplicateItem -ErrorAction Stop 2>$null } | Should Throw
        }

    }

    Context 'Silence on Errors' {

        $invalidPath =  "TestDrive:\foo"

        It 'Remains silent when Path does not exist' {
            $err = Get-DuplicateItem -Path $invalidPath -ErrorVariable err -ErrorAction SilentlyContinue

            $err | Should Be $null
        }

        It 'Remains silent when LiteralPath does not exist' {
            $err = Get-DuplicateItem -Path $invalidPath -ErrorVariable err -ErrorAction SilentlyContinue

            $err | Should Be $null
        }

        It 'Remains silent when pipeline object is not a string' {
            $invalidPathCollection = @( @( "foo", "bar") )
            $err = $invalidPathCollection | Get-DuplicateItem -ErrorVariable err -ErrorAction SilentlyContinue

            $err | Should Be $null
        }

        It 'Remains silent when pipeline object is not an existing Path' {
            $err = $invalidPath | Get-DuplicateItem -ErrorVariable err -ErrorAction SilentlyContinue

            $err | Should Be $null
        }

    }

    Context 'Finds duplicates' {

        $parentDir = "TestDrive:\parent"
        New-Item $parentDir -ItemType Directory -Force > $null
        'foo'           | Out-File -Path "$parentDir\file1"  -Encoding utf8 -Force
        'foo'           | Out-File -Path "$parentDir\file2" -Encoding utf8 -Force

        $childDir = "$parentDir\child"
        New-Item $childDir -ItemType Directory -Force > $null
        'foo'           | Out-File -Path "$childDir\file1"  -Encoding utf8 -Force
        'foo'           | Out-File -Path "$childDir\file2" -Encoding utf8 -Force

        It 'Returns duplicate file paths' {
            $result = Get-DuplicateItem -Path $parentDir

            $result.Count | Should -Be 2
        }

        It 'Returns duplicate file paths as hashtable' {
            $result = Get-DuplicateItem -Path $parentDir -AsHashtable

            $result | Should -BeOfType [hashtable]
        }

        It 'Returns duplicate file paths as hashtable with one key' {
            $result = Get-DuplicateItem -Path $parentDir -AsHashtable

            $result.Keys.Count | Should -Be 1
        }

        It 'Returns duplicate file paths as hashtable with two values' {
            $result = Get-DuplicateItem -Path $parentDir -AsHashtable

            # Note: Cannot use array syntax like $result.Keys[0] because that syntax returns a KeyCollection object instead of a string!
            # See: https://stackoverflow.com/questions/26552453/powershell-hashtable-keys-property-doesnt-return-the-keys-it-returns-a-keycol
            # This causes the accessing of a hashtable value (using its key) to return an array containing the value. Using the .Count property always returns 1.
            # $key = $result.Keys[0]
            $key = $result.Keys | Select-Object -First 1
            $result[$key].Count | Should -Be 2
        }

        It 'Returns duplicate file paths across all child folders' {
            $result = Get-DuplicateItem -Path $parentDir -AsHashtable -Recurse

            $result.Keys.Count | Should -Be 1
        }

        It 'Returns duplicate file paths across all child folders' {
            $result = Get-DuplicateItem -Path $parentDir -AsHashtable -Recurse

            # Note: Cannot use array syntax like $result.Keys[0] because that syntax returns a KeyCollection object instead of a string!
            # See: https://stackoverflow.com/questions/26552453/powershell-hashtable-keys-property-doesnt-return-the-keys-it-returns-a-keycol
            # This causes the accessing of a hashtable value (using its key) to return an array containing the value. Using the .Count property always returns 1.
            # $key = $result.Keys[0]
            $key = $result.Keys | Select-Object -First 1
            $result[$key].Count | Should -be 4
        }
    }

    Context 'Finds non-duplicatess' {

        $parentDir = "TestDrive:\parent"
        New-Item $parentDir -ItemType Directory -Force > $null
        'foo'           | Out-File -Path "$parentDir\file1"  -Encoding utf8 -Force
        'foo'           | Out-File -Path "$parentDir\file2" -Encoding utf8 -Force
        'foooooooo'     | Out-File -Path "$parentDir\file3" -Encoding utf8 -Force

        $childDir = "$parentDir\child"
        New-Item $childDir -ItemType Directory -Force > $null
        'foooooooo123'  | Out-File -Path "$childDir\file4" -Encoding utf8 -Force

        It 'Returns non-duplicates file paths' {
            $result = Get-DuplicateItem -Path $parentDir -Inverse

            $result | Should -BeOfType System.IO.FileInfo
        }

        It 'Returns non-duplicates file paths as hashtable with one key' {
            $result = Get-DuplicateItem -Path $parentDir -Inverse -AsHashtable

            $result.Keys.Count | Should -Be 1
        }

        It 'Returns non-duplicates file paths as hashtable with two values' {
            $result = Get-DuplicateItem -Path $parentDir -Inverse -AsHashtable

            # Note: Cannot use array syntax like $result.Keys[0] because that syntax returns a KeyCollection object instead of a string!
            # See: https://stackoverflow.com/questions/26552453/powershell-hashtable-keys-property-doesnt-return-the-keys-it-returns-a-keycol
            # This causes the accessing of a hashtable value (using its key) to return an array containing the value. Using the .Count property always returns 1.
            # $key = $result.Keys[0]
            $key = $result.Keys | Select-Object -First 1
            $result[$key].Count | Should -Be 1
        }

        It 'Returns non-duplicates file paths across all child folders' {
            $result = Get-DuplicateItem -Path $parentDir -Inverse -AsHashtable -Recurse

            $result.Keys.Count | Should -Be 2
        }

        It 'Returns non-duplicates file paths across all child folders' {
            $result = Get-DuplicateItem -Path $parentDir -Inverse -AsHashtable -Recurse

            # Note: Cannot use array syntax like $result.Keys[0] because that syntax returns a KeyCollection object instead of a string!
            # See: https://stackoverflow.com/questions/26552453/powershell-hashtable-keys-property-doesnt-return-the-keys-it-returns-a-keycol
            # This causes the accessing of a hashtable value (using its key) to return an array containing the value. Using the .Count property always returns 1.
            # $key = $result.Keys[0]
            $key = $result.Keys | Select-Object -First 1
            $result[$key].Count | Should -Be 1
        }

    }

}
