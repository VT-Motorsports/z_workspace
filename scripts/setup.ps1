$ErrorActionPreference = "Stop"

$ROOT = Split-Path -Parent $PSScriptRoot
$VENV = "$ROOT\.venv"
$SDK_BASE = "$ROOT\sdk"

$env:PIP_CACHE_DIR = "$ROOT\.pip-cache"

function Run {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Command,

        [Parameter(Position = 1, ValueFromRemainingArguments = $true)]
        [string[]]$Arguments
    )

    & $Command @Arguments

    if ($LASTEXITCODE -ne 0) {
        throw "$Command failed with exit code $LASTEXITCODE"
    }
}

function Refresh-Path {
    $machine = [Environment]::GetEnvironmentVariable("Path", "Machine")
    $user = [Environment]::GetEnvironmentVariable("Path", "User")
    $env:Path = "$machine;$user"

    $sevenZip = "$env:ProgramFiles\7-Zip"
    if ((Test-Path $sevenZip) -and ($env:Path -notlike "*$sevenZip*")) {
        $env:Path += ";$sevenZip"
    }
}

Write-Host ""
Write-Host "VT FSAE Zephyr Setup"
Write-Host "Workspace: $ROOT"
Write-Host ""

# Windows dependencies

if (!(Get-Command winget -ErrorAction SilentlyContinue)) {
    throw "winget is required. Install Microsoft App Installer and rerun setup."
}

$tools = @(
    @{ cmd = "git";   id = "Git.Git" },
    @{ cmd = "cmake"; id = "Kitware.CMake" },
    @{ cmd = "ninja"; id = "Ninja-build.Ninja" },
    @{ cmd = "gperf"; id = "oss-winget.gperf" },
    @{ cmd = "dtc";   id = "oss-winget.dtc" },
    @{ cmd = "wget";  id = "wget" },
    @{ cmd = "7z";    id = "7zip.7zip" }
)

foreach ($tool in $tools) {
    if (!(Get-Command $tool.cmd -ErrorAction SilentlyContinue)) {
        Write-Host "Installing $($tool.cmd)..."

        Run winget install `
            --id $tool.id `
            --exact `
            --silent `
            --accept-source-agreements `
            --accept-package-agreements
    }
}

Refresh-Path

# Python 3.12

$python312 = $false

if (Get-Command py -ErrorAction SilentlyContinue) {
    $python312 = [bool]((& py --list 2>$null) | Select-String "3\.12")
}

if (!$python312) {
    Write-Host "Installing Python 3.12..."

    Run winget install `
        --id Python.Python.3.12 `
        --exact `
        --silent `
        --accept-source-agreements `
        --accept-package-agreements

    Refresh-Path

    if (Get-Command py -ErrorAction SilentlyContinue) {
        $python312 = [bool]((& py --list 2>$null) | Select-String "3\.12")
    }

    if (!$python312) {
        throw "Python 3.12 was installed but is not visible yet. Restart the terminal and rerun setup."
    }
}

Write-Host "Python 3.12 found"

# Shared workspace venv

if (!(Test-Path "$VENV\Scripts\python.exe")) {
    Write-Host "Creating workspace venv..."
    Run py -3.12 -m venv $VENV
}

$PYTHON = "$VENV\Scripts\python.exe"

Write-Host "Installing West..."
Run $PYTHON -m pip install --upgrade pip
Run $PYTHON -m pip install --upgrade west

# Git setting for large Zephyr fetches

Write-Host "Configuring Git..."
Run git config --global http.version HTTP/1.1
    
# West workspace
# This repository intentionally acts as both the Git repository and the
# West workspace topdir. Creating .west/config directly avoids west init
# cloning Zephyr's default manifest repository.

if (!(Test-Path "$ROOT\.west\config")) {
    Write-Host "Creating West workspace config..."

    New-Item -ItemType Directory -Force "$ROOT\.west" | Out-Null

    @"
[manifest]
path = .
file = west.yml

[zephyr]
base = zephyr
"@ | Set-Content "$ROOT\.west\config" -Encoding ASCII
}

Push-Location $ROOT

try {
    Run $PYTHON -m west config manifest.path .
    Run $PYTHON -m west config manifest.file west.yml
    Run $PYTHON -m west config zephyr.base zephyr

    $topdir = (& $PYTHON -m west topdir).Trim()

    if ($LASTEXITCODE -ne 0) {
        throw "West workspace validation failed."
    }

    $expectedTopdir = [IO.Path]::GetFullPath($ROOT).TrimEnd('\')
    $actualTopdir = [IO.Path]::GetFullPath($topdir).TrimEnd('\')

    if ($actualTopdir -ne $expectedTopdir) {
        throw "Wrong West topdir: $actualTopdir (expected $expectedTopdir)"
    }

    Write-Host "West topdir: $actualTopdir"

    # Fetch Zephyr, z_vcu, and Zephyr modules

    Write-Host ""
    Write-Host "Updating West workspace..."

    $updated = $false

    for ($attempt = 1; $attempt -le 3; $attempt++) {
        & $PYTHON -m west update

        if ($LASTEXITCODE -eq 0) {
            $updated = $true
            break
        }

        if ($attempt -lt 3) {
            Write-Host "West update failed. Retrying ($($attempt + 1)/3)..."
            Start-Sleep -Seconds 5
        }
    }

    if (!$updated) {
        throw "west update failed after 3 attempts. Rerun setup to continue the partial download."
    }

    # Zephyr Python dependencies

    Write-Host ""
    Write-Host "Installing Zephyr Python dependencies..."
    Run $PYTHON -m west packages pip --install

    # Workspace-local minimal Zephyr SDK

    $SDK_VERSION = (Get-Content "$ROOT\zephyr\SDK_VERSION" -First 1).Trim()
    $SDK_DIR = "$SDK_BASE\zephyr-sdk-$SDK_VERSION"

    Write-Host ""
    Write-Host "Zephyr requires SDK $SDK_VERSION"

    if (!(Test-Path "$SDK_DIR\sdk_version")) {
        Write-Host "Installing ARM-only Zephyr SDK into $SDK_BASE..."

        New-Item -ItemType Directory -Force $SDK_BASE | Out-Null

        Run $PYTHON -m west sdk install `
            --version $SDK_VERSION `
            --install-base $SDK_BASE `
            --toolchains arm-zephyr-eabi
    }
    else {
        Write-Host "Zephyr SDK already installed at $SDK_DIR"
    }

    if (!(Test-Path "$SDK_DIR\sdk_version")) {
        throw "The SDK was not installed into $SDK_DIR. West may have reused an existing SDK installed elsewhere."
    }

    # Register Zephyr with CMake

    Write-Host ""
    Write-Host "Exporting Zephyr CMake package..."
    Run $PYTHON -m west zephyr-export
}
finally {
    Pop-Location
}

Write-Host ""
Write-Host "================================"
Write-Host "Setup complete"
Write-Host "================================"
Write-Host ""
Write-Host "For development, activate the venv with:"
Write-Host "    .\.venv\Scripts\Activate.ps1"
Write-Host ""
Write-Host "Then build the VCU with:"
Write-Host "    west build -p auto -b vcu_stm32 z_vcu"
