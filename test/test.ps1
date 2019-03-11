. "$( Split-Path $PSScriptRoot -Parent )/env.ps1"

Get-Module "$MODULE_NAME" | Remove-Module
Import-Module "$APP_DIR/$MODULE_NAME.psd1"

# Run tests
$res = Invoke-Pester -Script $APP_DIR -PassThru
if ($res.FailedCount -gt 0) {
    "$($res.FailedCount) tests failed."
    exit 1
}