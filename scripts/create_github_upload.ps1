# Creates GITHUB-UPLOAD-FINAL — one folder to drag into GitHub (replaces everything)
$ErrorActionPreference = "Stop"
$Root = Split-Path $PSScriptRoot -Parent
$Out = Join-Path $Root "GITHUB-UPLOAD-FINAL"
$Zip = "$Out.zip"

if (Test-Path $Out) { Remove-Item $Out -Recurse -Force }
if (Test-Path $Zip) { Remove-Item $Zip -Force }

$items = @(
    "Makefile",
    "Tweak.xm",
    "control",
    "StateScript.plist",
    ".github",
    "src",
    "scripts"
)

New-Item -ItemType Directory -Force -Path $Out | Out-Null
foreach ($item in $items) {
    $src = Join-Path $Root $item
    if (-not (Test-Path $src)) {
        Write-Warning "Missing: $item"
        continue
    }
    Copy-Item $src (Join-Path $Out $item) -Recurse -Force
}

@'
============================================================
ارفع هذا المجلد كامل — مرة واحدة — بدون أخطاء
============================================================

1) افتح: https://github.com/loop360zone/LoopScript

2) Add file → Upload files

3) اسحب كل محتويات مجلد GITHUB-UPLOAD-FINAL:
   - Makefile
   - Tweak.xm
   - control
   - StateScript.plist
   - .github
   - src
   - scripts

4) اختر: Replace existing files → Commit

5) Actions → Build StateScript deb
   (يتشغّل تلقائياً بعد Commit)

6) انتظر ✓ أخضر → Artifacts → Download .deb

============================================================
مهم
============================================================
- لا تلصق كود في محرر GitHub
- لا ترفع مجلد FIX
- احذف من الجذر إن وجد: Settings.mm و Settings.h
  (الصحيح داخل src/ فقط)

============================================================
'@ | Set-Content (Join-Path $Out "اقرأني.txt") -Encoding UTF8

Compress-Archive -Path "$Out\*" -DestinationPath $Zip -Force
Write-Output "Folder: $Out"
Write-Output "ZIP:    $Zip"
Write-Output "Files:  $((Get-ChildItem $Out -Recurse -File).Count)"
