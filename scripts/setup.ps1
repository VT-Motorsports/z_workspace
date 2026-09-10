$ErrorActionPreference = "Stop"

$ROOT = Split-Path -Parent $PSScriptRoot

$VENV = "$ROOT\.venv"

$SDK_VERSION = "0.16.5-1"
$SDK_DIR = "$ROOT\sdk\zephyr-sdk-$SDK_VERSION"
$SDK_ARCHIVE = "$ROOT\sdk\zephyr-sdk-$SDK_VERSION.7z"

$env:ZEPHYR_SDK_INSTALL_DIR = $SDK_DIR
$env:ZEPHYR_TOOLCHAIN_VARIANT = "zephyr"

Write-Host "VT FSAE Zephyr Setup"
Write-Host "Workspace: $ROOT"


#
# Dependencies
#

if (!(Get-Command winget -ErrorAction SilentlyContinue)) {
    throw "winget is required"
}

foreach ($tool in @(
    @{cmd="git"; id="Git.Git"},
    @{cmd="cmake"; id="Kitware.CMake"},
    @{cmd="ninja"; id="Ninja-build.Ninja"},
    @{cmd="7z"; id="7zip.7zip"}
)) {
    if (!(Get-Command $tool.cmd -ErrorAction SilentlyContinue)) {
        winget install `
            --id $tool.id `
            --silent `
            --accept-source-agreements `
            --accept-package-agreements
    }
}


#
# Python
#

if (!(py --list | Select-String "3.12")) {

    Write-Host "Installing Python 3.12"

    winget install `
        --id Python.Python.3.12 `
        --silent `
        --accept-source-agreements `
        --accept-package-agreements

    Write-Host "Python installed. Restart PowerShell and rerun."
    exit
}

Write-Host "Python 3.12 found"


#
# Venv
#

if (!(Test-Path "$VENV\Scripts\python.exe")) {

    Write-Host "Creating venv"

    py -3.12 -m venv $VENV
}

$PYTHON = "$VENV\Scripts\python.exe"

& $PYTHON -m pip install --upgrade pip
& $PYTHON -m pip install west


#
# Zephyr SDK
#

if (!(Test-Path "$SDK_DIR\setup.cmd")) {

    Write-Host "Downloading Zephyr SDK"

    New-Item "$ROOT\sdk" -ItemType Directory -Force | Out-Null

    curl.exe `
        -L `
        --retry 5 `
        --retry-delay 5 `
        -o $SDK_ARCHIVE `
        "https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.16.5-1/zephyr-sdk-0.16.5-1_windows-x86_64.7z"


    Write-Host "Extracting SDK"

    & 7z x $SDK_ARCHIVE "-o$ROOT\sdk" -y

    Remove-Item $SDK_ARCHIVE
}


#
# West workspace
#

Push-Location $ROOT

if (!(Test-Path "$ROOT\.west\config")) {

    Write-Host "Initializing West"

    Push-Location $ROOT

    & $PYTHON -m west init
    & $PYTHON -m west config manifest.path .

    Pop-Location
}


Write-Host "Updating West"

& $PYTHON -m west update

& $PYTHON -m west packages pip --install

& $PYTHON -m west zephyr-export

Pop-Location


Write-Host ""
Write-Host "Setup complete"
Write-Host ""
Write-Host "Activate:"
Write-Host ". .\scripts\activate.ps1"