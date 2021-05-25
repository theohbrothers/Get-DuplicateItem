# Get-DuplicateItem

[![Build Status](https://travis-ci.org/theohbrothers/Get-DuplicateItem.svg?branch=master)](https://travis-ci.org/theohbrothers/Get-DuplicateItem)

Gets duplicate or non-duplicate files.

## Install

Get-DuplicateItem works with `Powershell V3` and above on Windows, or [`Powershell Core`](https://github.com/powershell/powershell).

```powershell
Install-Module -Name Get-DuplicateItem -Force
```

## Usage

The cmdlet supports the same parameters as `Get-ChildItem`: `-Path`, `-LiteralPath`, `-Include`, `-Exclude`, and `-Recurse`.

`-AsHashtable` returns a hashtable containing `[string]$md5 = [System.Collections.ArrayList]$files`.

```powershell
# Get duplicate files in 'C:/folder1' only
Get-DuplicateItem -Path 'C:/folder1'

# Alternatively, you may pipe folder paths
'C:/folder1' | Get-DuplicateItem

# Or DirectoryInfo objects
Get-Item 'C:/folder1' | Get-DuplicateItem

# Get duplicate files in 'C:/folder1' and its descendents
Get-DuplicateItem -Path 'C:/folder1' -Recurse

# Get duplicate files in 'C:/folder1' and its descendents in the form: hash => FileInfo[]
Get-DuplicateItem -Path 'C:/folder1' -Recurse -AsHashtable

# Remove all duplicate items
Get-DuplicateItem -Path 'C:/folder1' | Remove-Item

# Get duplicate files in 'C:/folder1' and its descendents
Get-DuplicateItem -Path 'C:/folder1' -Recurse | Remove-Item
```

Use the `-Inverse` switch to get non-duplicates.

```powershell
# Get non-duplicate files in 'C:/folder1' only
Get-DuplicateItem -Path 'C:/folder1' -Inverse

# Get non-duplicate files in 'C:/folder1' and its descendents
Get-DuplicateItem -Path 'C:/folder1' -Inverse -Recurse

# Get non-duplicate files in 'C:/folder1' and its descendents in the form: hash => FileInfo[]
Get-DuplicateItem -Path 'C:/folder1' -Inverse -Recurse -AsHashtable

# Remove all non-duplicate files in 'C:/folder1' only
Get-DuplicateItem -Path 'C:/folder1' -Inverse | Remove-Item

# Remove all non-duplicate files in 'C:/folder1' and its descendents
Get-DuplicateItem -Path 'C:/folder1' -Inverse  -Recurse | Remove-Item
```

## Notes

The cmdlet calculates the md5 hash of each descendent file, to be able to identify duplicates and non-duplicates. Therefore if there are many large descendent files, it is normal for the Cmdlet to take several seconds to several minutes to complete.
