$ErrorActionPreference = 'Stop'

$NAMESPACE = 'leojonathanoh'

$BASE_DIR = $PSScriptRoot
$MODULE_NAME = (Get-Item $BASE_DIR).Name
$APP_DIR = "$BASE_DIR/app"
$APP_PUBLIC_DIR = "$APP_DIR/public"
$APP_PRIVATE_DIR = "$APP_DIR/private"
$APP_HELPER_DIR = "$APP_DIR/helper"
$RELEASE_DIR = "$BASE_DIR/release"
$TEST_DIR = "$BASE_DIR/test"
$PUBLISH_DIR = "$BASE_DIR/publish"
$PUBLISH_PSGALLERY_DIR = "$PUBLISH_DIR/psgallery"

$MODULE_VERSION = '0.0.1'
$MODULE_MANIFEST_FILE = "$APP_DIR/$MODULE_NAME.psd1"

