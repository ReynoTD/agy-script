# AGY Session Selector (`agys`)

A lightweight, fast console utility for Windows 11 to interactively list, sort, and select Antigravity CLI (`agy`) sessions without modifying the original installation or querying SQLite databases.

---

## Features

- **Zero external dependencies**: Built 100% with native Windows PowerShell and Batch scripts.
- **Fast and non-invasive**: Reads IDs and `LastWriteTime` directly from the filesystem without touching internal SQLite tables.
- **Chronological order**: Displays most recent sessions first.
- **Interactive navigation**: Arrow key navigation, page scrolling (<kbd>PgUp</kbd> / <kbd>PgDn</kbd>), <kbd>Enter</kbd> to launch, and <kbd>Esc</kbd> / <kbd>Q</kbd> to exit.
- **Seamless integration**: Opens the selected session in the current terminal with `agy --conversation=<ID>`.
- **1-Command installation & uninstallation**: Install or uninstall in seconds with a single terminal command.

---

## Requirements

- **Windows 10 / 11**
- **PowerShell 5.1+** or **PowerShell 7+ (pwsh)**
- **Antigravity CLI (`agy`)** installed and available in `PATH`.

---

## 📦 Quick Installation (1 Single Command)

### Method 1: Web One-Liner (Recommended)

Open **PowerShell** and run:

```powershell
irm https://raw.githubusercontent.com/reynoc/agys/main/install.ps1 | iex
```

> **What this does:**
>
> 1. Downloads `agys.ps1` and `agys.cmd` to `~/.agys/bin`.
> 2. Adds `~/.agys/bin` to your User `PATH` environment variable.
> 3. Makes `agys` immediately available in your terminal.

---

### Method 2: Local Installation (From Cloned / Downloaded Folder)

If you have downloaded or cloned this repository:

- **Option A:** Run `.\install.ps1` in PowerShell.
- **Option B:** Double-click `install.cmd`.
- **Option C (In-Place):** Run `.\install.ps1 -InPlace` to keep and use the files from the current folder.

---

### Method 3: PowerShell Gallery (Optional)

If published to the PowerShell Gallery:

```powershell
Install-Script -Name agys -Scope CurrentUser
```

---

## Uninstallation (1 Single Command)

To completely remove `agys` and clean your `PATH`:

```powershell
irm https://raw.githubusercontent.com/reynoc/agys/main/uninstall.ps1 | iex
```

_(Or run `.\uninstall.ps1` locally)._

---

## Usage

Simply run:

```powershell
agys
```

The interactive selector will appear:

```text
=== AGY Session Selector ===
Showing 28 of 28 conversations (sorted by last modification)

 > 8afe57c0-56d6-432e-86c3-4ba38185582b  [2026-10-09 15:20:10]
   4cda6ef4-0211-4a85-bfaa-53ff1fac1bac  [2026-10-07 16:07:22]
   e51e761e-3297-4414-b42b-7a0b665a4a73  [2026-09-17 17:22:10]
   582749fb-f3db-45b6-88a5-be4148834db2  [2026-09-14 01:08:44]
   ...

Up/Down Navigate | Enter Open | Esc Exit
```

### Keyboard Controls

| Key                               | Action                              |
| --------------------------------- | ----------------------------------- |
| <kbd>↑</kbd> / <kbd>↓</kbd>       | Move selection up / down            |
| <kbd>PgUp</kbd> / <kbd>PgDn</kbd> | Move up / down by a page            |
| <kbd>Home</kbd> / <kbd>End</kbd>  | Jump to first / last session        |
| <kbd>Enter</kbd>                  | Open selected conversation in `agy` |
| <kbd>Esc</kbd> or <kbd>Q</kbd>    | Cancel and exit                     |

---

## 📁 Project Structure

```text
agys/
├── agys.ps1       # Main PowerShell script with PSScriptInfo metadata & interactive UI
├── agys.cmd       # Batch wrapper for direct execution from cmd/PowerShell
├── install.ps1    # Universal installer (supports both local and remote web execution)
├── install.cmd    # Double-click / CMD wrapper for install.ps1
├── uninstall.ps1  # Universal uninstaller and PATH cleaner
└── README.md      # Documentation and installation guide
```

---

## ⚙️ Custom Conversations Path

If your conversations are stored in a custom folder, pass the path to `agys.ps1`:

```powershell
.\agys.ps1 -ConversationsPath "C:\Custom\Path\conversations"
```
