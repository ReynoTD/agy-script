<#PSScriptInfo
.VERSION 1.0.0
.GUID 4f5a3b98-1e42-4f67-8891-628b8cf40d62
.AUTHOR Reyno
.COMPANYNAME AGY
.COPYRIGHT (c) 2026. All rights reserved.
.TAGS Antigravity CLI agy session selector
.LICENSEURI https://opensource.org/licenses/MIT
.PROJECTURI https://github.com/reynoc/agys
.ICONURI
.EXTERNALMODULEDEPENDENCIES
.REQUIREDSCRIPTS
.EXTERNALSCRIPTDEPENDENCIES
.RELEASENOTES Initial release of AGY Session Selector (agys).
.PRIVATEDATA
#>

<#
.SYNOPSIS
    AGY Session Selector (agys)
    Interactive conversation selector for Antigravity CLI (agy).

.DESCRIPTION
    Lists, sorts, and selects saved conversations from Antigravity CLI
    (.db files in ~/.gemini/antigravity-cli/conversations) ordered by
    last modification date (most recent first), and opens the selected
    session with `agy --conversation=<ID>`.
#>

[CmdletBinding()]
param(
    [string]$ConversationsPath = (Join-Path $HOME ".gemini\antigravity-cli\conversations")
)

# Validate that directory exists
if (-not (Test-Path -LiteralPath $ConversationsPath -PathType Container)) {
    Write-Host "Conversations directory not found at: $ConversationsPath" -ForegroundColor Yellow
    exit 1
}

# Retrieve .db conversation files (excluding .db-shm and .db-wal)
$dbFiles = @(Get-ChildItem -LiteralPath $ConversationsPath -Filter "*.db" -File |
    Sort-Object LastWriteTime -Descending)

if ($dbFiles.Count -eq 0) {
    Write-Host "No saved conversations found in: $ConversationsPath" -ForegroundColor Yellow
    exit 0
}

# Check if console supports interactive input
if ([Console]::IsInputRedirected -or [Console]::IsOutputRedirected) {
    Write-Host "Non-interactive environment detected. Listing available conversations:" -ForegroundColor Cyan
    foreach ($file in $dbFiles) {
        $id = $file.BaseName
        $dateStr = $file.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
        Write-Host "  $id  ($dateStr)"
    }
    exit 0
}

# Save console state
$originalCursorVisible = [Console]::CursorVisible
$selectedIndex = 0
$topIndex = 0

try {
    [Console]::CursorVisible = $false

    # Interactive loop
    while ($true) {
        $windowHeight = try { [Console]::WindowHeight } catch { 25 }
        if ($windowHeight -lt 10) { $windowHeight = 25 }
        $pageSize = [Math]::Max(3, [Math]::Min(15, $windowHeight - 8))

        # Adjust scroll window
        if ($selectedIndex -lt $topIndex) {
            $topIndex = $selectedIndex
        }
        elseif ($selectedIndex -ge ($topIndex + $pageSize)) {
            $topIndex = $selectedIndex - $pageSize + 1
        }

        # Render UI
        Clear-Host
        Write-Host "=== AGY Session Selector ===" -ForegroundColor Cyan
        Write-Host ("Showing {0} of {1} conversations (sorted by last modification)`n" -f $dbFiles.Count, $dbFiles.Count) -ForegroundColor DarkGray

        $endIndex = [Math]::Min($dbFiles.Count - 1, $topIndex + $pageSize - 1)

        for ($i = $topIndex; $i -le $endIndex; $i++) {
            $file = $dbFiles[$i]
            $id = $file.BaseName
            $dateStr = $file.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
            $isCurrent = ($i -eq $selectedIndex)

            if ($isCurrent) {
                Write-Host " > " -ForegroundColor Green -NoNewline
                Write-Host "$id" -ForegroundColor Black -BackgroundColor Green -NoNewline
                Write-Host "  " -NoNewline
                Write-Host "[$dateStr]" -ForegroundColor Black -BackgroundColor Green
            } else {
                Write-Host "   " -NoNewline
                Write-Host "$id" -ForegroundColor White -NoNewline
                Write-Host "  " -NoNewline
                Write-Host "[$dateStr]" -ForegroundColor DarkGray
            }
        }

        # Scroll indicator if items exceed visible page
        if ($topIndex -gt 0 -or $endIndex -lt ($dbFiles.Count - 1)) {
            Write-Host ("`n  [Position {0}/{1} - use arrows or PgUp/PgDn to scroll]" -f ($selectedIndex + 1), $dbFiles.Count) -ForegroundColor DarkCyan
        } else {
            Write-Host ""
        }

        Write-Host "`nUp/Down Navigate | Enter Open | Esc Exit" -ForegroundColor Yellow

        # Read key
        $keyInfo = [Console]::ReadKey($true)

        switch ($keyInfo.Key) {
            'UpArrow' {
                if ($selectedIndex -gt 0) {
                    $selectedIndex--
                } else {
                    $selectedIndex = $dbFiles.Count - 1
                }
            }
            'DownArrow' {
                if ($selectedIndex -lt ($dbFiles.Count - 1)) {
                    $selectedIndex++
                } else {
                    $selectedIndex = 0
                }
            }
            'PageUp' {
                $selectedIndex = [Math]::Max(0, $selectedIndex - $pageSize)
            }
            'PageDown' {
                $selectedIndex = [Math]::Min($dbFiles.Count - 1, $selectedIndex + $pageSize)
            }
            'Home' {
                $selectedIndex = 0
            }
            'End' {
                $selectedIndex = $dbFiles.Count - 1
            }
            'Enter' {
                $selectedConversation = $dbFiles[$selectedIndex].BaseName
                [Console]::CursorVisible = $true
                Clear-Host
                Write-Host "Launching Antigravity CLI with conversation:" -ForegroundColor Cyan
                Write-Host "  $selectedConversation" -ForegroundColor Green
                Write-Host ""

                # Execute agy with selected conversation
                & agy --conversation=$selectedConversation
                return
            }
            'Escape' {
                [Console]::CursorVisible = $true
                Clear-Host
                Write-Host "Selection cancelled." -ForegroundColor Yellow
                return
            }
        }

        # Allow exit with 'q' or 'Q'
        if ($keyInfo.KeyChar -eq 'q' -or $keyInfo.KeyChar -eq 'Q') {
            [Console]::CursorVisible = $true
            Clear-Host
            Write-Host "Selection cancelled." -ForegroundColor Yellow
            return
        }
    }
}
finally {
    [Console]::CursorVisible = $originalCursorVisible
}
