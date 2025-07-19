# ========================
# PowerShell $PROFILE Setup
# Description: Custom profile with Oh My Posh, Git aliases, icons, PSReadLine, fzf, z, etc.
# =========================

# ----- Load Oh My Posh -----
#Import-Module oh-my-posh
oh-my-posh init pwsh --config "https://github.com/JanDeDobbeleer/oh-my-posh/blob/main/themes/atomic.omp.json" | Invoke-Expression

# ----- Terminal Icons (for "ls" style commands) -----
Import-Module -Name Terminal-Icons

# ----- PSReadLine Enhancements -----
Import-Module PSReadLine
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -Colors @{ InLinePrediction = "DarkGray" }

# ----- Git Functions (instead of alias) -----
function gs { git status @args }
function gco { git checkout @args }
function gl { git log --oneline --graph --all @args }
function gb { git branch @args }
function gf { git fetch origin @args }
#Set-Alias ltree "lsd --tree --depth 2 --icon always"
function ltree {
    param (
        [int]$depth
    )

    if (-not $depth) {
        Write-Host "Depth không có giá trị nhận vào, sẽ tự nhận giá trị là 3"
        lsd --tree --depth 3 --icon always
        return
    }

    lsd --tree --depth $depth --icon always
}
function scrcpy {
    Start-Process "D:\Scrcpy\scrcpy.exe"
}
function Aseprite {
    Start-Process 
}

# ----- Useful Shortcuts -----
function .. { Set-Location .. }
function ... { Set-Location ../.. }

function mkf {
    param (
        [string]$FileName
    )

    if (-not $FileName) {
        Write-Error "Bạn phải cung cấp tên file."
        return
    }

    New-Item -Path $FileName -ItemType "file" -Force
}

function cl {
    clear
}

# ----- Welcome Message -----
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "👋 Welcome, $env:USERNAME! Happy coding." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# =========================
# NEW: z - Directory jumping
# =========================

Import-Module z

# =========================
# NEW: fzf - Fuzzy finder
# =========================

    Import-Module PSFzf


# =========================
# NEW: Nerd Font Reminder
# =========================
# Ensure you're using a Nerd Font in Terminal settings (e.g., Fira Code Nerd Font)


