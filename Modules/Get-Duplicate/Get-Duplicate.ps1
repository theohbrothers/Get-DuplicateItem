# Search a given path for duplicates, returning a search result object
# In recurse mode, duplicates will be located among all files found across all folder nodes starting from a given path
# In inverse mode, unique files will be located instead of duplicate files.
# If hashtable mode is specified, a hashtable will be returned in format @{ [string]"$md5" = [FileInfo[]]$files }
function Get-Duplicate {
    param(
        [Parameter(ValueFromPipeline, ParameterSetName="Pipeline",
            #Position=0,
            Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [PSObject[]]$InputObject
    ,
        [Parameter(ParameterSetName="Path",
            Position=0,
            Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({
            if ((! (Test-Path -Path $_ -PathType Container) ) #-or
                #($_.IndexOfAny([System.IO.Path]::GetInvalidFileNameChars()) -ne -1) #-or
                #($_.IndexOfAny([System.IO.Path]::GetInvalidPathChars()) -ne -1)
                ) {
                return $false
            }
            $true
        })]
        [string]$Path 
    ,
        [Parameter(ParameterSetName="LiteralPath",
            Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({
            if ((! (Test-Path -Literal $_ -PathType Container) ) #-or
                #($_.IndexOfAny([System.IO.Path]::GetInvalidFileNameChars()) -ne -1) #-or
                #($_.IndexOfAny([System.IO.Path]::GetInvalidPathChars()) -ne -1)
                ) {
                return $false
            }
            $true
        })]
        [string]$LiteralPath
    ,
        [Parameter(Mandatory=$false)]
        [switch]$Recurse
    ,
        [Parameter(Mandatory=$false)]
        [string]$Exclude = ''
    ,
        [Parameter(Mandatory=$false)]
        [string]$Include = ''
    ,
        [Parameter(Mandatory=$false)]
        [string]$ExcludeDirectory = ''
    ,
        [Parameter(Mandatory=$false)]
        [switch]$Inverse
    ,
        [Parameter(Mandatory=$false)]
        [switch]$AsHashtable
    )

    begin {
        $ErrorActionPreference = "Stop"
    }
    process {
        if ($InputObject) {
            if ($InputObject -is [array]) { 
                $InputObject | % {
                    if ($_ -is [string]) {
                        $PSBoundParameters.Remove('InputObject') > $null
                        Get-Duplicate -Path $_ @PSBoundParameters
                    }elseif ($_ -is [System.IO.FileInfo]) {
                        $PSBoundParameters.Remove('InputObject') > $null
                        Get-Duplicate -Path $_.FullName @PSBoundParameters
                    }
                }
            }
        }else {
            $fileSearchParams = @{
                Path = $Path
                File = $true
                Recurse = $Recurse
                #ReadOnly = $true
            }
            if ($Exclude) {
                $fileSearchParams['Exclude'] = $Exclude
            }
            if ($Include) {
                $fileSearchParams['Include'] = $Include
            } 

            $hashes_unique = @{} # format: md5str => FileInfo
            $hashes_duplicates = @{} # format: md5str => FileInfo[]
            # Get all files found only within this directory
            & { if ($ExcludeDirectory) {
                    Get-ChildItem @fileSearchParams | Where-Object { $_.Directory.Name -notmatch $ExcludeDirectory }
                }else {
                    Get-ChildItem @fileSearchParams
                }
            } | Sort-Object Name, Extension | ForEach-Object {
                $md5 = (Get-FileHash -LiteralPath $_.FullName -Algorithm MD5).Hash # md5 hash of this file
                if ( ! $hashes_unique.ContainsKey($md5) ) {
                    $hashes_unique[$md5] = $_
                }else {
                    # Duplicate!
                    if (!$hashes_duplicates.ContainsKey($md5)) {
                        $hashes_duplicates[$md5] = [System.Collections.Arraylist]@()
                        $hashes_duplicates[$md5].Add($hashes_unique[$md5]) > $null
                    }
                    $hashes_duplicates[$md5].Add($_) > $null
                }
            }

            # The first object will be the Original object.
            @($hashes_duplicates.Keys) | ForEach-Object {
                $key = $_
                $hashes_duplicates[$key] = $hashes_duplicates[$key] | Sort-Object { $_.Name.Length }
            }

            if ($Inverse) {
                $hashes_duplicates.Keys | ForEach-Object {
                    if ($hashes_unique.ContainsKey($_)) {
                        $hashes_unique.Remove($_)
                    }
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
        }
    }
}