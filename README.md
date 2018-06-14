# Get-Duplicate
A Powershell module that find duplicate files.
To widen the scope to be across-folder, use the `-Recurse` switch. By default, the scope is within-folder.
To list unique files, use the `-Inverse` switch.
To filter `-Include`, `-Exclude`, and `-ExcludeDirectory` switches
Additionally, `-AsHashtable` returns a hashtable containing: `[string]$md5` = `[array]$files`

## Command line
```powershell
NAME
    Get-Duplicate

SYNTAX
    Get-Duplicate [-InputObject <psobject[]>] [-Recurse] [-Exclude <string>] [-Include <string>] [-ExcludeDirectory <string>] [-Inverse] [-AsHashtable]  [<CommonParameters>]

    Get-Duplicate [-Path] <string> [-Recurse] [-Exclude <string>] [-Include <string>] [-ExcludeDirectory <string>] [-Inverse] [-AsHashtable]  [<CommonParameters>]

	Get-Duplicate -LiteralPath <string> [-Recurse] [-Exclude <string>] [-Include <string>] [-ExcludeDirectory <string>] [-Inverse] [-AsHashtable]  [<CommonParameters>]
```