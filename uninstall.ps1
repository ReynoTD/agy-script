<#
.SYNOPSIS
    Uninstalls AGY Session Selector (agys).

.DESCRIPTION
    Supports both local and remote one-liner web uninstallation:
      irm https://raw.githubusercontent.com/<user>/agys/main/uninstall.ps1 | iex

    Removes agys from ~/.agys/bin and removes its directory from the user's PATH environment variable.
#>

[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

Write-Host "=== Uninstalling AGY Session Selector (agys) ===" -ForegroundColor Cyan

$targetDir = Join-Path $HOME ".agys\bin"
$sourceDir = $PSScriptRoot

# Remove from User PATH
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if (-not [string]::IsNullOrWhiteSpace($userPath)) {
    $pathEntries = $userPath -split ';' | Where-Object { $_ -ne "" }
    $updatedEntries = $pathEntries | Where-Object {
        $cleanEntry = $_.TrimEnd('\')
        $cleanEntry -ine $targetDir.TrimEnd('\') -and
        ([string]::IsNullOrWhiteSpace($sourceDir) -or $cleanEntry -ine $sourceDir.TrimEnd('\'))
    }
    $newPath = $updatedEntries -join ';'
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    Write-Host "[OK] Cleaned from User PATH." -ForegroundColor Green
}

# Remove ~/.agys directory if it exists
$agysHome = Join-Path $HOME ".agys"
if (Test-Path -LiteralPath $agysHome) {
    Remove-Item -LiteralPath $agysHome -Recurse -Force
    Write-Host "[OK] Removed directory: $agysHome" -ForegroundColor Green
}

Write-Host "`nUninstallation completed." -ForegroundColor Yellow
