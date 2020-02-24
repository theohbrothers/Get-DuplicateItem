# Interactive script to update the module manifest. If module manifest does not exist, it creates one.

. "$( Split-Path $PSScriptRoot -Parent )/env.ps1"

function Get-FunctionsToExport {
    Get-ChildItem "$APP_MODULE_PUBLIC_DIR/*" -exclude *.Tests.ps1 | ForEach-Object { $_.BaseName }
}

$params = @{
    Path = "$MODULE_MANIFEST_FILE"

    RootModule = "$MODULE_NAME.psm1"
    ModuleVersion = $MODULE_VERSION
    Author = $( git config user.name )
    CompanyName  = 'The Oh Brothers'
    Copyright = "Copyright (c) $( Get-Date -Format 'yyyy' ) by $( git config user.name ), licensed under MIT License"
    Description = "A module to find and list duplicate files"
    PowerShellVersion = '2.0'
    FunctionsToExport = @( Get-FunctionsToExport )

    #Category = ''
    Tags = 'duplicate', 'item'
    ProjectUri = "https://github.com/$PROJECT_NAMESPACE/$MODULE_NAME"
    IconUri = ''
    LicenseUri = "https://github.com/$PROJECT_NAMESPACE/$MODULE_NAME/blob/$MODULE_VERSION/LICENSE"
    ReleaseNotes  = "https://github.com/$PROJECT_NAMESPACE/$MODULE_NAME/releases/tag/$MODULE_VERSION"
    Prerelease = ''
}

# Create a module manifest if it does not exist
# Or, update an existing module manifest
if (! ( Test-Path -Path $MODULE_MANIFEST_FILE ) ) {
    New-ModuleManifest -Path $MODULE_MANIFEST_FILE
    $content = Get-Content $MODULE_MANIFEST_FILE
    $content | Set-Content $MODULE_MANIFEST_FILE -Encoding utf8
}
Update-ModuleManifest @params
