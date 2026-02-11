# Helper script to build Formula SAE applications
# Usage: .\build-app.ps1 <app-name> <board-name>

param(
    [Parameter(Mandatory=$true)]
    [string]$App,
    
    [Parameter(Mandatory=$true)]
    [string]$Board
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $App)) {
    Write-Host "Error: Application '$App' not found in workspace." -ForegroundColor Red
    Write-Host ""
    Write-Host "Did you clone it? Try:"
    Write-Host "  git clone https://github.com/your-org/$App"
    exit 1
}

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Building: $App" -ForegroundColor Cyan
Write-Host "Board: $Board" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

Push-Location $App
try {
    west build -b $Board .
    
    Write-Host ""
    Write-Host "======================================" -ForegroundColor Green
    Write-Host "Build complete!" -ForegroundColor Green
    Write-Host "======================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "To flash:"
    Write-Host "  cd $App"
    Write-Host "  west flash"
} finally {
    Pop-Location
}
