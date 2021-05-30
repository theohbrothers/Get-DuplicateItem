$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Get-DuplicateItem" -Tag 'Unit' {

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

    Context 'Terminating errors' {

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

    Context 'Behavior' {

        $parentDir = "TestDrive:\parent"
        New-Item $parentDir -ItemType Directory -Force > $null
        'foo'           | Out-File "$parentDir\file1"  -Encoding utf8 -Force
        'foo'           | Out-File "$parentDir\file2" -Encoding utf8 -Force
        'foooooooo'     | Out-File "$parentDir\file3" -Encoding utf8 -Force

        $childDir = "$parentDir\child"
        New-Item $childDir -ItemType Directory -Force > $null
        'foo'           | Out-File "$childDir\file1"  -Encoding utf8 -Force
        'foo'           | Out-File "$childDir\file2" -Encoding utf8 -Force
        'foooooooo123'  | Out-File "$childDir\file4" -Encoding utf8 -Force

        It 'Returns duplicate file paths' {
            $result = Get-DuplicateItem -Path $parentDir

            ($result | Measure-Object).Count | Should -Be 2
            $result | Should -BeOfType [System.IO.FileInfo]
        }

        It 'Returns duplicate file paths in all descendent folders' {
            $result = Get-DuplicateItem -Path $parentDir -Recurse

            ($result | Measure-Object).Count | Should -Be 4
            $result | Should -BeOfType [System.IO.FileInfo]
        }

        It 'Returns duplicate file paths as hashtable: <hash> => [System.IO.FileInfo][]' {
            $result = Get-DuplicateItem -Path $parentDir -AsHashtable

            $result | Should -BeOfType [hashtable]
            $result.Keys.Count | Should -Be 1
            $result.Values.Count | Should -Be 1
            # Note: Cannot use array syntax like $result.Keys[0] because that syntax returns a KeyCollection object instead of a string!
            # See: https://stackoverflow.com/questions/26552453/powershell-hashtable-keys-property-doesnt-return-the-keys-it-returns-a-keycol
            # This causes the accessing of a hashtable value (using its key) to return an array containing the value. Using the .Count property always returns 1.
            # $key = $result.Keys[0]
            $key = $result.Keys | Select-Object -First 1
            $value = $result[$key]
            $key | Should -BeOfType [string]
            ,$value | Should -BeOfType [System.Collections.ArrayList]
            $value | Should -BeOfType [System.IO.FileInfo]
        }

        It 'Returns duplicate file paths as hashtable: <hash> => [System.IO.FileInfo][] in all descendent folders' {
            $result = Get-DuplicateItem -Path $parentDir -AsHashtable -Recurse

            $result | Should -BeOfType [hashtable]
            $result.Keys.Count | Should -Be 1
            $result.Values.Count | Should -Be 1
            # Note: Cannot use array syntax like $result.Keys[0] because that syntax returns a KeyCollection object instead of a string!
            # See: https://stackoverflow.com/questions/26552453/powershell-hashtable-keys-property-doesnt-return-the-keys-it-returns-a-keycol
            # This causes the accessing of a hashtable value (using its key) to return an array containing the value. Using the .Count property always returns 1.
            # $key = $result.Keys[0]
            $key = $result.Keys | Select-Object -First 1
            $value = $result[$key]
            $key | Should -BeOfType [string]
            ,$value | Should -BeOfType [System.Collections.ArrayList]
            $value | Should -BeOfType [System.IO.FileInfo]
        }

        It 'Returns duplicate file paths in all descendent folders' {
            $result = Get-DuplicateItem -Path $parentDir -Recurse

            ($result | Measure-Object).Count | Should -Be 4
            $result | Should -BeOfType [System.IO.FileInfo]
        }

        It 'Returns non-duplicate file paths' {
            $result = Get-DuplicateItem -Path $parentDir -Inverse

            ($result | Measure-Object).Count | Should -Be 1
            $result | Should -BeOfType [System.IO.FileInfo]
        }

        It 'Returns non-duplicate file paths in all descendent folders' {
            $result = Get-DuplicateItem -Path $parentDir -Inverse -Recurse

            ($result | Measure-Object).Count | Should -Be 2
            $result | Should -BeOfType [System.IO.FileInfo]
        }

        It 'Returns non-duplicate file paths as hashtable: <hash> => [System.IO.FileInfo][]' {
            $result = Get-DuplicateItem -Path $parentDir -Inverse -AsHashtable

            $result | Should -BeOfType [hashtable]
            $result.Keys.Count | Should -Be 1
            $result.Values.Count | Should -Be 1
            # Note: Cannot use array syntax like $result.Keys[0] because that syntax returns a KeyCollection object instead of a string!
            # See: https://stackoverflow.com/questions/26552453/powershell-hashtable-keys-property-doesnt-return-the-keys-it-returns-a-keycol
            # This causes the accessing of a hashtable value (using its key) to return an array containing the value. Using the .Count property always returns 1.
            # $key = $result.Keys[0]
            $key = $result.Keys | Select-Object -First 1
            $value = $result[$key]
            $key | Should -BeOfType [string]
            ,$value | Should -BeOfType [System.Collections.ArrayList]
            $value | Should -BeOfType [System.IO.FileInfo]
        }

        It 'Returns non-duplicate file paths as hashtable: <hash> => [System.IO.FileInfo][] in all descendent folders' {
            $result = Get-DuplicateItem -Path $parentDir -Inverse -AsHashtable -Recurse

            $result | Should -BeOfType [hashtable]
            $result.Keys.Count | Should -Be 2
            $result.Values.Count | Should -Be 2
            # Note: Cannot use array syntax like $result.Keys[0] because that syntax returns a KeyCollection object instead of a string!
            # See: https://stackoverflow.com/questions/26552453/powershell-hashtable-keys-property-doesnt-return-the-keys-it-returns-a-keycol
            # This causes the accessing of a hashtable value (using its key) to return an array containing the value. Using the .Count property always returns 1.
            # $key = $result.Keys[0]
            $key = $result.Keys | Select-Object -First 1
            $value = $result[$key]
            $key | Should -BeOfType [string]
            ,$value | Should -BeOfType [System.Collections.ArrayList]
            $value | Should -BeOfType [System.IO.FileInfo]
        }

    }

}
