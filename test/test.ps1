. "$( Split-Path $PSScriptRoot -Parent )/env.ps1"

Set-StrictMode -Version Latest
$global:PesterDebugPreference_ShowFullErrors = $true

Get-Module "$MODULE_NAME" | Remove-Module
Import-Module "$APP_DIR/$MODULE_NAME.psd1" -Force

# Run tests
$res = Invoke-Pester -Script $APP_DIR -PassThru
if ($res.FailedCount -gt 0) {
    "$($res.FailedCount) tests failed."
    exit 1
}
