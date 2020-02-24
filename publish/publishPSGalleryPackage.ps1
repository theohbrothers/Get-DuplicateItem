param (
    [Parameter(Mandatory)]
    [string] $ApiKey
)

. "$( Split-Path $PSScriptRoot -Parent )/env.ps1"

#Get-Module "$MODULE_NAME" | Remove-Module
#Import-Module "$SRC_MODULE_DIR/$MODULE_NAME.psd1" -Force
#Publish-Module -Name $MODULE_NAME -NuGetApiKey $ApiKey

Publish-Module -Path $SRC_MODULE_DIR -NuGetApiKey $ApiKey
