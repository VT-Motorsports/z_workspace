$ROOT = Split-Path -Parent $PSScriptRoot

& "$ROOT\.venv\Scripts\Activate.ps1"

$env:ZEPHYR_SDK_INSTALL_DIR="$ROOT\sdk\zephyr-sdk-0.16.5-1"
$env:ZEPHYR_TOOLCHAIN_VARIANT="zephyr"

Write-Host "FSAE Zephyr environment active"