# PowerShell Profile

Cấu hình PowerShell 7 cá nhân (`$PROFILE`) kèm các module đi cùng: prompt Oh My Posh, icon cho file/thư mục, gợi ý lệnh theo lịch sử, alias Git, fuzzy finder (fzf), nhảy thư mục nhanh (z) và một số hàm tiện ích tự viết.

## Cấu trúc thư mục

```
PowerShell/
├── Microsoft.PowerShell_profile.ps1   # File profile chính, chạy mỗi khi mở pwsh
├── Modules/
│   ├── PSFzf/2.6.10/                   # Tích hợp fzf vào PowerShell / PSReadLine
│   ├── Terminal-Icons/0.11.0/          # Hiển thị icon theo loại file khi ls
│   └── z/1.1.14/                       # Nhảy nhanh tới thư mục hay dùng
└── Scripts/                            # Thư mục script của PowerShellGet (đang trống)
```

## Chức năng trong profile

### Giao diện terminal

| Thành phần | Mô tả |
|---|---|
| **Oh My Posh** | Khởi tạo prompt với theme `atomic`. |
| **Terminal-Icons** | Thêm icon và màu theo phần mở rộng file khi dùng `ls` / `Get-ChildItem`. |
| **PSReadLine** | Bật gợi ý lệnh từ lịch sử (`PredictionSource History`), hiển thị dạng danh sách (`ListView`), chữ gợi ý màu xám (`DarkGray`). |
| **Lời chào** | In `👋 Welcome, <USERNAME>! Happy coding.` mỗi khi mở terminal. |

### Lệnh tắt cho Git

| Lệnh | Tương đương |
|---|---|
| `gs`  | `git status` |
| `gco` | `git checkout` |
| `gl`  | `git log --oneline --graph --all` |
| `gb`  | `git branch` |
| `gf`  | `git fetch origin` |

Mọi tham số truyền thêm đều được chuyển tiếp cho `git`, ví dụ `gco -b feature/x` hoặc `gl -10`.

### Điều hướng và quản lý file

| Lệnh | Mô tả |
|---|---|
| `..`  | Lên thư mục cha. |
| `...` | Lên 2 cấp thư mục. |
| `lsf` | Liệt kê file, gồm cả file ẩn (`ls -Force`). |
| `ltree [depth]` | Hiển thị cây thư mục bằng `lsd` kèm icon. Không truyền `depth` thì mặc định là 3. |
| `mkf <tên-file>` | Tạo file mới (tạo luôn thư mục cha nếu chưa có). |
| `cl`  | Xoá màn hình (`clear`). |
| `z <từ-khoá>` | Nhảy tới thư mục hay truy cập nhất khớp với từ khoá (module **z**, xem bên dưới). |

### Tiện ích khác

| Lệnh | Mô tả |
|---|---|
| `scrcpy` | Mở `D:\Scrcpy\scrcpy.exe` để mirror màn hình Android. |
| `NewWebProject <tên-dự-án>` | Tạo khung dự án web HTML/CSS/JS rồi `cd` vào thư mục đó. |

`NewWebProject` tạo ra cấu trúc sau:

```
<tên-dự-án>/
├── index.html          # Có sẵn khung HTML, link tới style.css và main.js
├── about.html
├── contact.html
├── package.json        # name + version 1.0.0
├── README.md
├── .gitignore
├── LICENSE
├── assets/
│   ├── css/  style.css (reset + style mặc định), components.css
│   ├── js/   main.js (log khi DOM sẵn sàng), utils.js
│   ├── img/
│   ├── fonts/
│   └── icons/
├── vendor/
│   ├── bootstrap/
│   └── aos/
├── docs/
├── dist/
└── tests/
    └── main.test.js
```

## Các module đi kèm

### PSFzf 2.6.10

Bọc [fzf](https://github.com/junegunn/fzf) cho PowerShell. Khi import, module gán phím tắt PSReadLine sau (chỉ gán nếu phím đó chưa bị PSReadLine dùng):

| Phím | Chức năng |
|---|---|
| `Ctrl+t` | Chọn file/đường dẫn bằng fzf và chèn vào dòng lệnh. |
| `Ctrl+r` | Tìm lệnh trong lịch sử bằng fzf. |
| `Alt+c`  | Chọn thư mục bằng fzf rồi `cd` vào đó. |
| `Alt+a`  | Tìm tham số đã dùng trong lịch sử lệnh. |

`Ctrl+r` và `Tab` mặc định đã được PSReadLine dùng nên sẽ giữ hành vi cũ. Muốn dùng fzf cho các phím này, thêm vào profile:

```powershell
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }
```

Các lệnh có thể gọi trực tiếp:

| Lệnh | Mô tả |
|---|---|
| `Invoke-Fzf` | Gọi fzf với dữ liệu từ pipeline. |
| `Invoke-FuzzyEdit` | Chọn file rồi mở bằng editor. |
| `Invoke-FuzzyHistory` | Chọn và chạy lại lệnh trong lịch sử. |
| `Invoke-FuzzySetLocation` | Chọn thư mục con rồi `cd` vào. |
| `Invoke-FuzzyZLocation` | Chọn thư mục từ dữ liệu của z. |
| `Invoke-FuzzyKillProcess` | Chọn tiến trình để kill. |
| `Invoke-FuzzyGitStatus` | Chọn file từ `git status`. |
| `Invoke-PsFzfGitFiles` / `GitBranches` / `GitHashes` / `GitStashes` / `GitTags` | Duyệt file, nhánh, commit, stash, tag của Git bằng fzf. |
| `Invoke-PsFzfRipgrep` | Tìm nội dung file bằng ripgrep + fzf. |
| `Enable-PsFzfAliases` | Bật alias ngắn: `fe`, `fh`, `fd`, `fz`, `fkill`, `fgs`... |
| `Set-PsFzfOption` | Cấu hình phím tắt, alias, keybinding Git. |

### Terminal-Icons 0.11.0

Hiển thị icon Nerd Font và màu sắc theo loại file/thư mục khi liệt kê. Có thể đổi theme bằng `Set-TerminalIconsTheme`, xem theme bằng `Show-TerminalIconsTheme`.

### z 1.1.14

Ghi nhớ các thư mục đã `cd` vào và cho phép nhảy nhanh tới đó:

```powershell
z foo          # Tới thư mục hay dùng nhất khớp "foo"
z foo -o t     # Tới thư mục khớp "foo" được truy cập gần nhất
z -l foo       # Liệt kê các thư mục khớp "foo"
z -x           # Xoá thư mục hiện tại khỏi dữ liệu
z -clean       # Xoá các đường dẫn không còn tồn tại
```

## Yêu cầu cài đặt

- [PowerShell 7+](https://github.com/PowerShell/PowerShell)
- [Oh My Posh](https://ohmyposh.dev/) — `winget install JanDeDobbeleer.OhMyPosh`
- Một [Nerd Font](https://www.nerdfonts.com/) (ví dụ FiraCode Nerd Font), đặt làm font của terminal để hiện icon
- [fzf](https://github.com/junegunn/fzf) có trong `PATH` — `winget install junegunn.fzf`
- [lsd](https://github.com/lsd-rs/lsd) cho lệnh `ltree` — `winget install lsd-rs.lsd`
- [scrcpy](https://github.com/Genymobile/scrcpy) đặt tại `D:\Scrcpy\` (nếu dùng lệnh `scrcpy`)

## Cài đặt trên máy mới

```powershell
git clone <url-repo> "$HOME\Documents\PowerShell"
```

Thư mục `Modules/z/1.1.14` được lưu dưới dạng tham chiếu tới một repo git khác (không có `.gitmodules`), nên sau khi clone thư mục này sẽ trống. Cài lại module z bằng:

```powershell
Install-Module z -AllowClobber -Scope CurrentUser
```

Mở lại terminal để profile được nạp.
