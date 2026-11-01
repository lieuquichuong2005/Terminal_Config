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
# "gl" là alias có sẵn của Get-Location và alias được ưu tiên hơn function, nên phải gỡ trước
Remove-Alias gl -Force -ErrorAction SilentlyContinue
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
    # Ưu tiên scrcpy trong PATH, nếu không có thì dùng bản ở D:\Scrcpy
    $exe = Get-Command scrcpy -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty Source
    if (-not $exe -and (Test-Path "D:\Scrcpy\scrcpy.exe")) {
        $exe = "D:\Scrcpy\scrcpy.exe"
    }

    if (-not $exe) {
        Write-Host "❌ Không tìm thấy scrcpy. Cài bằng: winget install Genymobile.scrcpy"
        return
    }

    if ($args) {
        Start-Process $exe -ArgumentList $args
    }
    else {
        Start-Process $exe
    }
}

# ----- Useful Shortcuts -----
function .. { Set-Location .. }
function ... { Set-Location ../.. }
function lsf { Get-ChildItem -Force @args }

function mkf {
    param (
        [string]$FileName
    )

    if (-not $FileName) {
        Write-Error "Bạn phải cung cấp tên file."
        return
    }

    # New-Item -Force sẽ xoá trắng file đã có, nên file tồn tại thì chỉ cập nhật thời gian sửa
    if (Test-Path -LiteralPath $FileName) {
        (Get-Item -LiteralPath $FileName).LastWriteTime = Get-Date
        Write-Host "File '$FileName' đã tồn tại, giữ nguyên nội dung."
        return
    }

    New-Item -Path $FileName -ItemType "file" -Force
}

function cl {
    clear
}

function NewWebProject {
    param (
        [string]$projectName
    )

    if (-not $projectName) {
        Write-Host "❌ Bạn phải cung cấp tên dự án."
        return
    }

    # Không tạo đè lên thư mục đã có nội dung, tránh ghi đè index.html, README.md, .gitignore...
    if ((Test-Path -LiteralPath $projectName) -and (Get-ChildItem -LiteralPath $projectName -Force | Select-Object -First 1)) {
        Write-Host "❌ Thư mục '$projectName' đã tồn tại và không trống."
        return
    }

    # npm chỉ chấp nhận tên viết thường, không dấu cách, không ký tự đặc biệt
    $packageName = ($projectName.ToLower() -replace '[^a-z0-9._-]+', '-').Trim('-', '.', '_')

    # Tạo thư mục gốc
    New-Item -Path $projectName -ItemType Directory -Force | Out-Null
    Set-Location $projectName

    # ====== Tạo file HTML ======
    $htmlTemplate = @"
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>$projectName</title>
  <link rel="stylesheet" href="assets/css/style.css">
</head>
<body>
  <h1>Xin chào, đây là $projectName</h1>
  <script src="assets/js/main.js"></script>
</body>
</html>
"@

    Set-Content -Path "index.html" -Value $htmlTemplate
    Set-Content -Path "about.html" -Value "<h1>About Page</h1>"
    Set-Content -Path "contact.html" -Value "<h1>Contact Page</h1>"

    # ====== File cấu hình và tài liệu ======
    Set-Content -Path "package.json" -Value "{`n  `"name`": `"$packageName`",`n  `"version`": `"1.0.0`"`n}"
    Set-Content -Path "README.md" -Value "# $projectName`nWebsite HTML/CSS/JS cơ bản."
    New-Item -Name ".gitignore" -ItemType File -Force | Out-Null
    New-Item -Name "LICENSE" -ItemType File -Force | Out-Null

    # ====== Tạo thư mục assets ======
    New-Item -Path "assets/css" -ItemType Directory -Force | Out-Null
    New-Item -Path "assets/js" -ItemType Directory -Force | Out-Null
    New-Item -Path "assets/img" -ItemType Directory -Force | Out-Null
    New-Item -Path "assets/fonts" -ItemType Directory -Force | Out-Null
    New-Item -Path "assets/icons" -ItemType Directory -Force | Out-Null

    # CSS template
    $cssTemplate = @"
/* Reset cơ bản */
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

/* Style mặc định */
body {
  font-family: Arial, sans-serif;
  background: #f4f4f9;
  color: #333;
  line-height: 1.6;
  padding: 20px;
}
"@
    Set-Content -Path "assets/css/style.css" -Value $cssTemplate
    New-Item -Path "assets/css/components.css" -ItemType File -Force | Out-Null

    # JS template
    $jsTemplate = @"
document.addEventListener('DOMContentLoaded', () => {
  console.log('🚀 $projectName đã sẵn sàng!');
});
"@
    Set-Content -Path "assets/js/main.js" -Value $jsTemplate
    New-Item -Path "assets/js/utils.js" -ItemType File -Force | Out-Null

    # ====== Các thư mục khác ======
    New-Item -Path "vendor/bootstrap" -ItemType Directory -Force | Out-Null
    New-Item -Path "vendor/aos" -ItemType Directory -Force | Out-Null

    New-Item -Path "docs" -ItemType Directory -Force | Out-Null
    New-Item -Path "dist" -ItemType Directory -Force | Out-Null
    New-Item -Path "tests" -ItemType Directory -Force | Out-Null
    New-Item -Path "tests/main.test.js" -ItemType File -Force | Out-Null

    Write-Host "✅ Dự án '$projectName' đã được tạo thành công!"
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
# Mặc định PSFzf không ghi đè Ctrl+r của PSReadLine, nên phải chỉ định rõ để tìm lịch sử bằng fzf
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'


# =========================
# NEW: Nerd Font Reminder
# =========================
# Ensure you're using a Nerd Font in Terminal settings (e.g., Fira Code Nerd Font)


