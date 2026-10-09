<#
.SYNOPSIS
    Installs AGY Session Selector (agys) to the user's environment.

.DESCRIPTION
    Supports both local and remote one-liner web installation:
      irm https://raw.githubusercontent.com/<user>/agys/main/install.ps1 | iex

    Installs agys files to standard user location (~/.agys/bin) and adds it
    persistently to the User PATH environment variable.
#>

[CmdletBinding()]
param(
    [string]$RepoBaseUrl = "https://raw.githubusercontent.com/ReynoTD/agy-script/main",
    [switch]$InPlace
)

$ErrorActionPreference = "Stop"

Write-Host "=== Installing AGY Session Selector (agys) ===" -ForegroundColor Cyan

$sourceDir = $PSScriptRoot
$isLocal = -not [string]::IsNullOrWhiteSpace($sourceDir) -and (Test-Path (Join-Path $sourceDir "agys.ps1"))

if ($InPlace -and $isLocal) {
    # In-place installation
    $targetDir = $sourceDir
    Write-Host "Configuring in-place installation at: $targetDir" -ForegroundColor DarkGray
} else {
    # Standard user tools directory: ~/.agys/bin
    $targetDir = Join-Path $HOME ".agys\bin"
    if (-not (Test-Path -LiteralPath $targetDir)) {
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    }

    if ($isLocal) {
        Write-Host "Copying local files from: $sourceDir" -ForegroundColor DarkGray
        Copy-Item -Path (Join-Path $sourceDir "agys.ps1") -Destination $targetDir -Force
        Copy-Item -Path (Join-Path $sourceDir "agys.cmd") -Destination $targetDir -Force
    } else {
        Write-Host "Downloading latest files from repository: $RepoBaseUrl" -ForegroundColor DarkGray
        $agysPs1Url = "$RepoBaseUrl/agys.ps1"
        $agysCmdUrl = "$RepoBaseUrl/agys.cmd"

        $destPs1 = Join-Path $targetDir "agys.ps1"
        $destCmd = Join-Path $targetDir "agys.cmd"

        Invoke-RestMethod -Uri $agysPs1Url -OutFile $destPs1
        Invoke-RestMethod -Uri $agysCmdUrl -OutFile $destCmd
    }
    Write-Host "Files installed to: $targetDir" -ForegroundColor DarkGray
}

# Update User PATH
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ([string]::IsNullOrWhiteSpace($userPath)) {
    $pathEntries = @()
} else {
    $pathEntries = $userPath -split ';' | Where-Object { $_ -ne "" }
}

# Check if already in User PATH
$alreadyInPath = $false
foreach ($entry in $pathEntries) {
    if ($entry.TrimEnd('\') -ieq $targetDir.TrimEnd('\')) {
        $alreadyInPath = $true
        break
    }
}

if (-not $alreadyInPath) {
    $newPath = if ($userPath) { "$userPath;$targetDir" } else { $targetDir }
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    Write-Host "[OK] Added to User PATH: $targetDir" -ForegroundColor Green
} else {
    Write-Host "[INFO] Directory is already in User PATH." -ForegroundColor Yellow
}

# Update current session PATH so it works immediately
if ($env:Path -notlike "*$targetDir*") {
    $env:Path = "$targetDir;$env:Path"
}

Write-Host "`nInstallation completed successfully!" -ForegroundColor Green
Write-Host "You can now type 'agys' in any terminal window." -ForegroundColor Cyan
