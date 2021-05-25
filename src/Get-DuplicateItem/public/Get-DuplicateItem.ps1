<#
.SYNOPSIS
A Powershell module that find duplicate files within a given folder.

.DESCRIPTION
A Powershell module that find duplicate files within a given folder. It may also expand it's search scope to all descendent items of that folder.

.PARAMETER InputObject
Parameter description

.PARAMETER Path
Folder to search for duplicate files.

.PARAMETER LiteralPath
Folder to search for duplicate files.

.PARAMETER Recurse
Expand the scope of the duplicate file search to be across all descendent files of the given folder.

.PARAMETER Exclude
Omits the specified items. The value of this parameter qualifies the -Path parameter. Enter a path element or pattern, such as "*.txt". Wildcards are permitted.

.PARAMETER Include
Gets only the specified items. The value of this parameter qualifies the -Path parameter. Enter a path element or pattern, such as "*.txt". Wildcards are permitted.

.PARAMETER Inverse
Get only non-duplicate files. By default the Cmdlet returns duplicate files.

.PARAMETER AsHashtable
Get the result as a Hashtable, where duplicates are grouped in file hashes.

.EXAMPLE
# Get duplicate files in 'C:/folder1' only
Get-DuplicateItem -Path 'C:/folder1'

.EXAMPLE
# Get duplicate files in 'C:/folder1' and its descendents
Get-DuplicateItem -Path 'C:/folder1' -Recurse

.EXAMPLE
# Get non-duplicate files in 'C:/folder1' and its descendents
Get-DuplicateItem -Path 'C:/folder1' -Recurse -Inverse

.EXAMPLE
# Remove all duplicate items
Get-DuplicateItem Get-Item 'C:/folder1' | Remove-Item

.EXAMPLE
# Remove all non-duplicate items
Get-DuplicateItem 'C:/folder1' -Inverse | Remove-Item

.NOTES
The cmdlet calculates the md5 hash of each descendent file, to be able to identify duplicates and non-duplicates. Therefore if there are many large descendent files, it is normal for the Cmdlet to take several seconds to several minutes to complete.
#>
function Get-DuplicateItem {
    [CmdletBinding(DefaultParameterSetName='Path')]
    param(
        [Parameter(ParameterSetName="Path", Mandatory=$true, Position=0)]
        [string]$Path
    ,
        [Parameter(ParameterSetName="LiteralPath", Mandatory=$true)]
        [string]$LiteralPath
    ,
        [Parameter()]
        [switch]$Recurse
    ,
        [Parameter()]
        [string]$Exclude = ''
    ,
        [Parameter()]
        [string]$Include = ''
    ,
        [Parameter()]
        [switch]$Inverse
    ,
        [Parameter()]
        [switch]$AsHashtable
    ,
        [Parameter(ValueFromPipeline, ParameterSetName="Pipeline", Mandatory=$false)]
        [string]$InputObject
    )

    process {
        try {
            if ($InputObject) {
                $Path = $_
            }

            if ($Path) {
                if (! (Test-Path -Path $Path -ErrorAction SilentlyContinue) ) {
                    throw "Path $Path does not exist."
                }
            }
            if ($LiteralPath) {
                if (! (Test-Path -LiteralPath $Path -ErrorAction SilentlyContinue) ) {
                    throw "LiteralPath $Path does not exist."
                }
            }

            $fileSearchParams = @{
                File = $true
                Recurse = $Recurse
                #ReadOnly = $true
            }
            if ($Path) {
                $fileSearchParams['Path'] = $Path
            }
            if ($LiteralPath) {
                $fileSearchParams['LiteralPath'] = $LiteralPath
            }
            if ($Exclude) {
                $fileSearchParams['Exclude'] = $Exclude
            }
            if ($Include) {
                $fileSearchParams['Include'] = $Include
            }

            $hashesUnique = @{} # format: md5str => FileInfo[]
            $hashesDuplicates = @{} # format: md5str => FileInfo[]
            # Get all files found only within this directory
            Get-ChildItem @fileSearchParams | Sort-Object Name, Extension | ForEach-Object {
                $md5 = (Get-FileHash -LiteralPath $_.FullName -Algorithm MD5).Hash # md5 hash of this file
                if ( ! $hashesUnique.ContainsKey($md5) ) {
                    $hashesUnique[$md5] = [System.Collections.Arraylist]@()
                    $hashesUnique[$md5].Add( $_ ) > $null
                }else {
                    # Duplicate!
                    if (!$hashesDuplicates.ContainsKey($md5)) {
                        $hashesDuplicates[$md5] = [System.Collections.Arraylist]@()
                        $hashesDuplicates[$md5].Add($hashesUnique[$md5][0]) > $null
                    }
                    $hashesDuplicates[$md5].Add($_) > $null
                }
            }

            # The first object will be the Original object (shortest file name).
            # @($hashesDuplicates.Keys) | ForEach-Object {
            #     $md5 = $_
            #     $hashesDuplicates[$md5] = $hashesDuplicates[$md5] | Sort-Object { $_.Name.Length }
            # }

            if ($Inverse) {
                # Remove any keys that are in the duplicates hash
                $( $hashesUnique.Keys ) | ? { $hashesDuplicates.ContainsKey($_) } | ForEach-Object {
                    $hashesUnique.Remove($_) > $null
                }

                if ($AsHashtable) {
                    $hashesUnique
                }else {
                    # Unwrap the Arraylist so we retrun System.IO.FileInfo
                    $hashesUnique.Values | ForEach-Object {
                        $_
                    }
                }
            }else {
                if ($AsHashtable) {
                    $hashesDuplicates
                }else {
                    # Unwrap the Arraylist so we retrun System.IO.FileInfo
                    $hashesDuplicates.Values | ForEach-Object {
                        $_
                    }
                }
            }
        }catch {
            Write-Error -ErrorRecord $_
        }
    }
}
