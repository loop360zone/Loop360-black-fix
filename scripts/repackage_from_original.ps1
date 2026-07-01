# Rebuild .deb using the ORIGINAL data.tar.lzma (same bytes as working 1.0.3 package).
# ESign is sensitive to deb payload format — keep original data blob.

param(
    [string]$SourceDeb = "D:\Downloads\com.statescript.hack_1.0.3-Fixed-AntiCrash+debug_iphoneos-arm.deb",
    [string]$Root = ""
)

$ErrorActionPreference = "Stop"
if ([string]::IsNullOrWhiteSpace($Root)) {
    $Root = Split-Path $PSScriptRoot -Parent
}
$OutDir = Join-Path $Root "packages"
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

if (-not (Test-Path $SourceDeb)) {
    throw "Original deb not found: $SourceDeb"
}

$Stage = Join-Path $env:TEMP "statescript_repack"
if (Test-Path $Stage) { Remove-Item $Stage -Recurse -Force }
New-Item -ItemType Directory -Force -Path $Stage | Out-Null

# Extract ar members from original deb
$bytes = [IO.File]::ReadAllBytes($SourceDeb)
$pos = 8
$dataTarLzma = $null
while ($pos -lt $bytes.Length - 2) {
    $name = [Text.Encoding]::ASCII.GetString($bytes, $pos, 16).Trim().TrimEnd('/')
    $sizeStr = [Text.Encoding]::ASCII.GetString($bytes, $pos + 48, 10).Trim()
    if ($sizeStr -eq '') { break }
    $size = [int]$sizeStr
    $dataStart = $pos + 60
    $fileName = if ($name -match '/') { $name.Split('/')[1] } else { $name }
    $chunk = $bytes[$dataStart..($dataStart + $size - 1)]
    if ($fileName -eq "data.tar.lzma") { $dataTarLzma = $chunk }
    elseif ($fileName -eq "debian-binary") {
        [IO.File]::WriteAllBytes((Join-Path $Stage "debian-binary"), $chunk)
    }
    $pos = $dataStart + $size + ($size % 2)
}

if (-not $dataTarLzma) { throw "data.tar.lzma missing in source deb" }

# Update plist inside payload (optional) — extract, patch, recompress
$PayloadDir = Join-Path $Stage "payload"
New-Item -ItemType Directory -Force -Path $PayloadDir | Out-Null
$dataPath = Join-Path $Stage "data.tar.lzma"
[IO.File]::WriteAllBytes($dataPath, $dataTarLzma)
tar --lzma -xf $dataPath -C $PayloadDir

$plistPath = Join-Path $PayloadDir "Library\MobileSubstrate\DynamicLibraries\StateScript.plist"
$plistContent = @"
{
    Filter = {
        Bundles = (
            "com.Chillgaming.oneState",
            "com.Chillgaming.oneState2"
        );
    };
}
"@
Set-Content -Path $plistPath -Value $plistContent -Encoding UTF8

Remove-Item $dataPath -Force
tar --lzma -cf $dataPath -C $PayloadDir .

# Fresh control from project
Copy-Item (Join-Path $Root "control") (Join-Path $Stage "control") -Force
Set-Location $Stage
tar -czf (Join-Path $Stage "control.tar.gz") control

$version = (Select-String -Path (Join-Path $Stage "control") -Pattern "^Version:\s*(.+)$").Matches[0].Groups[1].Value.Trim()
$debName = "com.statescript.hack_${version}_iphoneos-arm.deb"
$debPath = Join-Path $OutDir $debName

$arBytes = New-Object System.Collections.Generic.List[byte]
function Add-ArEntry([string]$name, [byte[]]$data) {
    $header = New-Object byte[] 60
    $nameBytes = [Text.Encoding]::ASCII.GetBytes($name.PadRight(16).Substring(0, 16))
    [Array]::Copy($nameBytes, 0, $header, 0, 16)
    $mtime = [Text.Encoding]::ASCII.GetBytes(("{0,10}" -f [int][double]::Parse((Get-Date -UFormat %s))))
    [Array]::Copy($mtime, 0, $header, 16, 10)
    $sizeStr = [System.Text.Encoding]::ASCII.GetBytes(("{0,10}" -f $data.Length))
    [Array]::Copy($sizeStr, 0, $header, 48, 10)
    $header[58] = 0x60
    $header[59] = 0x0A
    $script:arBytes.AddRange([System.Text.Encoding]::ASCII.GetBytes("!<arch>`n"))
    $script:arBytes.AddRange($header)
    $script:arBytes.AddRange($data)
    if ($data.Length % 2 -eq 1) { $script:arBytes.Add(0x0A) }
}

Add-ArEntry "debian-binary" ([Text.Encoding]::ASCII.GetBytes("2.0`n"))
Add-ArEntry "control.tar.gz" ([IO.File]::ReadAllBytes((Join-Path $Stage "control.tar.gz")))
Add-ArEntry "data.tar.lzma" ([IO.File]::ReadAllBytes($dataPath))
[IO.File]::WriteAllBytes($debPath, $arBytes.ToArray())

# Also keep exact original for sideload fallback
Copy-Item $SourceDeb (Join-Path $OutDir "com.statescript.hack_1.0.3-Fixed-AntiCrash-WORKING.deb") -Force

Write-Output "Fixed deb: $debPath"
Write-Output "Original backup: $(Join-Path $OutDir 'com.statescript.hack_1.0.3-Fixed-AntiCrash-WORKING.deb')"
