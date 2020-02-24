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

.PARAMETER ExcludeDirectory
Omits searching any descendent directory matching the entered name or pattern. Enter a name or pattern, such as "*secret". Wildcards are permitted.

.PARAMETER Inverse
Get only non-duplicate files. By default the Cmdlet returns duplicate files.

.PARAMETER AsHashtable
Get the result as a Hashtable, where duplicates are grouped in file hashes.

.EXAMPLE
Get-DuplicateItem -Path 'C:/my_folder_with_duplicates'

.EXAMPLE
Get-DuplicateItem -Path 'C:/my_folder_with_duplicates' -Recurse -ExcludeDirectory 'specialDirectory'

.NOTES
When using the -Recurse parameter, the md5 hash of each descendent file has to be calculated, in order for
comparison against all other descendent files' md5 hash.
Therefore, if using Get-DuplicateItem with the -Recurse parameter on a folder containing many large descendent files,
it is to be expected that the Cmdlet might take several seconds to several minutes to complete, depending on the
size of those files.
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
        [string]$ExcludeDirectory = ''
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

    begin {
        $callerEA = $ErrorActionPreference
        $ErrorActionPreference = "Stop"

        if ($callerEA -ne $ErrorActionPreference) {
            $PSDefaultParameterValues['Get-ChildItem:ErrorAction'] = $callerEA
            $PSDefaultParameterValues['Where-Object:ErrorAction'] = $callerEA
            $PSDefaultParameterValues['ForEach-Object:ErrorAction'] = $callerEA
        }
    }
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

            $hashes_unique = @{} # format: md5str => FileInfo[]
            $hashes_duplicates = @{} # format: md5str => FileInfo[]
            # Get all files found only within this directory
            & { if ($ExcludeDirectory) {
                    Get-ChildItem @fileSearchParams | Where-Object { $_.Directory.Name -notmatch "^$( [regex]::Escape($ExcludeDirectory) )$" }
                }else {
                    Get-ChildItem @fileSearchParams
                }
            } | Sort-Object Name, Extension | ForEach-Object {
                $md5 = (Get-FileHash -LiteralPath $_.FullName -Algorithm MD5).Hash # md5 hash of this file
                if ( ! $hashes_unique.ContainsKey($md5) ) {
                    $hashes_unique[$md5] = @( $_ )
                }else {
                    # Duplicate!
                    if (!$hashes_duplicates.ContainsKey($md5)) {
                        $hashes_duplicates[$md5] = [System.Collections.Arraylist]@()
                        $hashes_duplicates[$md5].Add($hashes_unique[$md5][0]) > $null
                    }
                    $hashes_duplicates[$md5].Add($_) > $null
                }
            }

            # The first object will be the Original object (shortest file name).
            # @($hashes_duplicates.Keys) | ForEach-Object {
            #     $md5 = $_
            #     $hashes_duplicates[$md5] = $hashes_duplicates[$md5] | Sort-Object { $_.Name.Length }
            # }

            if ($Inverse) {
                # Remove any keys that are in the duplicates hash
                $( $hashes_unique.Keys ) | ? { $hashes_duplicates.ContainsKey($_) } | ForEach-Object {
                    $hashes_unique.Remove($_) > $null
                }

                if ($AsHashtable) {
                    $hashes_unique
                }else {
                    $hashes_unique.Values
                }
            }else {
                if ($AsHashtable) {
                    $hashes_duplicates
                }else {
                    $hashes_duplicates.Values
                }
            }
        }catch {
            Write-Error -ErrorRecord $_ -ErrorAction $callerEA
        }
    }
}
