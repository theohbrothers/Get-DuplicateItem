# Get-Duplicate

A Powershell module that find duplicate files within a given folder.

To widen the duplicate search scope to be across all descendent files, use the `-Recurse` switch. By default, the scope is within-folder.

To filter the search, use the `-Include`, `-Exclude`, and `-ExcludeDirectory` switches.

To list unique files, use the `-Inverse` switch.

The module supports pipelining either folder paths, or DirectoryInfo objects.

Additionally, `-AsHashtable` returns a hashtable containing: 

```powershell
[string]$md5 = [arraylist]$files
```

## Example

```powershell
Get-Duplicate -Path 'C:/folder1' -Recurse

# Pipeline DirectoryInfo objects
Get-Item 'C:/folder1' | Get-Duplicate 

# Pipeline folder paths
'C:/folder1' | Get-Duplicate 
```

## Command line

```powershell
NAME
    Get-Duplicate

SYNTAX
    Get-Duplicate [-InputObject <psobject[]>] [-Recurse] [-Exclude <string>] [-Include <string>] [-ExcludeDirectory <string>] [-Inverse] [-AsHashtable]  [<CommonParameters>]

    Get-Duplicate [-Path] <string> [-Recurse] [-Exclude <string>] [-Include <string>] [-ExcludeDirectory <string>] [-Inverse] [-AsHashtable]  [<CommonParameters>]

	Get-Duplicate -LiteralPath <string> [-Recurse] [-Exclude <string>] [-Include <string>] [-ExcludeDirectory <string>] [-Inverse] [-AsHashtable]  [<CommonParameters>]
```