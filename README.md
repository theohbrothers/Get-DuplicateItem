# Get-Duplicate

A Powershell module that find duplicate files within a given folder.

To widen the duplicate search scope to be across all descendent files, use the `-Recurse` switch. By default, the scope is within the immediate folder.

To filter the search, use the `-Include`, `-Exclude`, and `-ExcludeDirectory` switches.

To list unique files, use the `-Inverse` switch.

The module supports pipelining either folder paths, or DirectoryInfo objects.

Additionally, `-AsHashtable` returns a hashtable containing:

```powershell
[string]$md5 = [arraylist]$files
```

## Install

```powershell
Install-Module -Name Pester -Force
```

## Examples

```powershell
# Get duplicate files in this folder only
Get-Duplicate -Path 'C:/folder1'

# Get duplicate files in this folder and its descendents
Get-Duplicate -Path 'C:/folder1' -Recurse

# Get non-duplicate files in this folder and its descendents
Get-Duplicate -Path 'C:/folder1' -Recurse -Inverse

# Alternatively, you may pipeline DirectoryInfo objects
Get-Item 'C:/folder1' | Get-Duplicate

# Or folder paths
'C:/folder1' | Get-Duplicate
```