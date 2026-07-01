# Creates one organized folder + ZIP for GitHub upload or backup
$ErrorActionPreference = "Stop"

$Root = Split-Path $PSScriptRoot -Parent
$OutName = "StateScript-Ready-Upload"
$Out = Join-Path (Split-Path $Root -Parent) $OutName
$Zip = "$Out.zip"

if (Test-Path $Out) { Remove-Item $Out -Recurse -Force }
if (Test-Path $Zip) { Remove-Item $Zip -Force }
New-Item -ItemType Directory -Force -Path $Out | Out-Null

function Copy-Tree($rel) {
    $src = Join-Path $Root $rel
    if (-not (Test-Path $src)) { return }
    $dst = Join-Path $Out $rel
    $parent = Split-Path $dst -Parent
    if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
    Copy-Item $src $dst -Recurse -Force
}

# --- Source (GitHub root layout) ---
$files = @(
    "Makefile",
    "control",
    "Tweak.xm",
    "StateScript.plist",
    ".gitignore"
)
foreach ($f in $files) {
    Copy-Item (Join-Path $Root $f) (Join-Path $Out $f) -Force
}
Copy-Tree ".github"
Copy-Tree "src"
Copy-Tree "scripts"

# --- deb folder ---
$debDir = Join-Path $Out "deb"
New-Item -ItemType Directory -Force -Path $debDir | Out-Null

$workingDeb = Join-Path $Root "packages\com.statescript.hack_1.0.3-Fixed-AntiCrash-WORKING.deb"
$v104Deb = Join-Path $Root "packages\com.statescript.hack_1.0.4_iphoneos-arm.deb"
if (Test-Path $workingDeb) {
    Copy-Item $workingDeb (Join-Path $debDir "01-USE-NOW_1.0.3-WORKING_has-login.deb") -Force
}
if (Test-Path $v104Deb) {
    Copy-Item $v104Deb (Join-Path $debDir "02-repack_1.0.4_same-dylib-as-old.deb") -Force
}

# Rebuild proper 1.0.4 from original if source exists
$orig = "D:\Downloads\com.statescript.hack_1.0.3-Fixed-AntiCrash+debug_iphoneos-arm.deb"
if (Test-Path $orig) {
    & (Join-Path $Root "scripts\repackage_from_original.ps1") | Out-Null
    if (Test-Path $v104Deb) {
        Copy-Item $v104Deb (Join-Path $debDir "03-repack_1.0.4_ESign-format.deb") -Force
    }
}

# --- inspect (readable files) ---
$inspect = Join-Path $Out "inspect-no-encryption"
New-Item -ItemType Directory -Force -Path $inspect | Out-Null
Copy-Item (Join-Path $Root "control") (Join-Path $inspect "control.txt") -Force
Copy-Item (Join-Path $Root "StateScript.plist") (Join-Path $inspect "StateScript.plist") -Force
$extractPlist = "C:\Users\HP\Desktop\dddd\deb_extract_full\Library\MobileSubstrate\DynamicLibraries"
if (Test-Path $extractPlist) {
    Copy-Item "$extractPlist\StateScript.plist" (Join-Path $inspect "StateScript.plist.inside-old-deb") -Force
    Copy-Item "$extractPlist\StateScript.dylib" (Join-Path $inspect "StateScript.dylib.from-old-deb") -Force
}

# --- guide ---
@'
============================================================
StateScript — حزمة جاهزة للرفع
============================================================

هذا المجلد فيه كل شي منظم:

  .github/          → لبناء .deb على GitHub Actions
  src/              → السورس الجديد (بدون Login)
  scripts/          → سكربتات البناء
  Makefile, Tweak.xm, control, StateScript.plist

  deb/              → ملفات .deb للتثبيت
  inspect-no-encryption/  → ملفات للفحص (plist, control, dylib)

============================================================
GitHub — ارفع محتويات هذا المجلد (مو المجلد نفسه)
============================================================

1. github.com → repo statescript
2. Add file → Upload files
3. اسحب كل شي من داخل StateScript-Ready-Upload:
   - .github, src, scripts, Makefile, ...
   (لا ترفع deb/ و inspect/ إذا تبي repo نظيف — اختياري)
4. Actions → Build StateScript deb → Run workflow
5. حمّل .deb جديد بدون Login

============================================================
ESign — أي deb تستخدم؟
============================================================

  deb/01-USE-NOW_1.0.3-WORKING_has-login.deb
      → يشتغل الحين + علامة SS + Login

  deb/03-repack_1.0.4_ESign-format.deb
      → نفس dylib + تغليف أحدث (Login لسه موجود)

  deb جديد بدون Login = بعد GitHub Actions فقط

============================================================
'@ | Set-Content (Join-Path $Out "READ_ME_FIRST.txt") -Encoding UTF8

Compress-Archive -Path "$Out\*" -DestinationPath $Zip -Force

Write-Output "Package folder: $Out"
Write-Output "ZIP file:       $Zip"
Write-Output "Size:           $((Get-Item $Zip).Length) bytes"
Get-ChildItem $Out -Recurse -File | Measure-Object | ForEach-Object { Write-Output "Files:          $($_.Count)" }
