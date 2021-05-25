# Get-DuplicateItem

[![Build Status](https://travis-ci.org/theohbrothers/Get-DuplicateItem.svg?branch=master)](https://travis-ci.org/theohbrothers/Get-DuplicateItem)

A Powershell module to find duplicate files.

To widen the duplicate search scope to be across all descendent files, use the `-Recurse` switch. By default, the scope is within the immediate folder.

To filter the search, use the `-Include`, `-Exclude` switches.

To list unique files, use the `-Inverse` switch.

The module supports pipelining either folder paths, or DirectoryInfo objects.

Additionally, `-AsHashtable` returns a hashtable containing:

```powershell
[string]$md5 = [arraylist]$files
```

## Install

Get-DuplicateItem works with `Powershell V3` and above on Windows, or [`Powershell Core`](https://github.com/powershell/powershell).

```powershell
Install-Module -Name Get-DuplicateItem -Force
```

## Examples

```powershell
# Get duplicate files in 'C:/folder1' only
Get-DuplicateItem -Path 'C:/folder1'

# Get duplicate files in 'C:/folder1' and its descendents
Get-DuplicateItem -Path 'C:/folder1' -Recurse

# Get non-duplicate files in 'C:/folder1' and its descendents
Get-DuplicateItem -Path 'C:/folder1' -Recurse -Inverse

# Alternatively, you may pipe folder paths
'C:/folder1' | Get-DuplicateItem

# Or DirectoryInfo objects
Get-Item 'C:/folder1' | Get-DuplicateItem

# Finally to remove all duplicate items
Get-Item 'C:/folder1' | Get-DuplicateItem | Remove-Item

# Finally to remove all unique items
Get-Item 'C:/folder1' | Get-DuplicateItem -Inverse | Remove-Item
```
