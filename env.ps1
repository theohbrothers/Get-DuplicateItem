$ErrorActionPreference = 'Stop'

$BASE_DIR = $PSScriptRoot

$REPO_NAMESPACE = (Get-Item $BASE_DIR).Parent.Name
$REPO_NAME = (Get-Item $BASE_DIR).Name

$MODULE_NAME = $REPO_NAME
$MODULE_VERSION = $( git --no-pager tag -l --sort=-version:refname | Select -First 1 )

$PUBLISH_DIR = Join-Path $BASE_DIR "publish"
$PUBLISH_PSGALLERY_DIR = Join-Path $PUBLISH_DIR "psgallery"
$RELEASE_DIR = Join-Path $BASE_DIR "release"
$SRC_DIR = Join-Path $BASE_DIR "src"
$SRC_MODULE_DIR = Join-Path $SRC_DIR $MODULE_NAME
$SRC_MODULE_PUBLIC_DIR = Join-Path $SRC_MODULE_DIR "public"
$TEST_DIR = Join-Path $BASE_DIR "test"

$MODULE_MANIFEST_FILE = Join-Path $SRC_MODULE_DIR "$MODULE_NAME.psd1"
