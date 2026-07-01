# Builds a .deb on Windows when StateScript.dylib is already compiled (arm64).
# Usage: .\scripts\package_deb.ps1 [-DylibPath path\to\StateScript.dylib]

param(
    [string]$DylibPath = "",
    [string]$OutDir = ""
)

$ErrorActionPreference = "Stop"
$Root = Split-Path $PSScriptRoot -Parent

if ([string]::IsNullOrWhiteSpace($DylibPath)) {
    $DylibPath = Join-Path $Root "dist\StateScript.dylib"
}
if (-not (Test-Path $DylibPath)) {
    throw "Missing dylib: $DylibPath`nDownload it from GitHub Actions artifact or copy after Mac build."
}

if ([string]::IsNullOrWhiteSpace($OutDir)) {
    $OutDir = Join-Path $Root "packages"
}
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

$Stage = Join-Path $env:TEMP "statescript_deb_stage"
if (Test-Path $Stage) { Remove-Item $Stage -Recurse -Force }
$Payload = Join-Path $Stage "payload"
$LibDir = Join-Path $Payload "Library\MobileSubstrate\DynamicLibraries"
New-Item -ItemType Directory -Force -Path $LibDir | Out-Null

Copy-Item (Join-Path $Root "StateScript.plist") (Join-Path $LibDir "StateScript.plist") -Force
Copy-Item $DylibPath (Join-Path $LibDir "StateScript.dylib") -Force
Copy-Item (Join-Path $Root "control") (Join-Path $Stage "control") -Force

Set-Location $Stage
tar -czf (Join-Path $Stage "control.tar.gz") control
if ($LASTEXITCODE -ne 0) { throw "Failed to create control.tar.gz" }
tar --lzma -cf (Join-Path $Stage "data.tar.lzma") -C $Payload .
if ($LASTEXITCODE -ne 0) { throw "Failed to create data.tar.lzma" }

$version = (Select-String -Path (Join-Path $Stage "control") -Pattern "^Version:\s*(.+)$").Matches[0].Groups[1].Value.Trim()
$debName = "com.statescript.hack_${version}_iphoneos-arm.deb"
$debPath = Join-Path $OutDir $debName

$debianBinaryPath = Join-Path $Stage "debian-binary"
"2.0`n" | Out-File -FilePath $debianBinaryPath -Encoding ascii -NoNewline
$arBytes = New-Object System.Collections.Generic.List[byte]
function Add-ArEntry([string]$name, [byte[]]$data) {
    $header = New-Object byte[] 60
    $nameBytes = [System.Text.Encoding]::ASCII.GetBytes($name.PadRight(16).Substring(0, 16))
    [Array]::Copy($nameBytes, 0, $header, 0, 16)
    $mtime = [System.Text.Encoding]::ASCII.GetBytes(("{0,10}" -f [int][double]::Parse((Get-Date -UFormat %s))))
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

Add-ArEntry "debian-binary" ([System.Text.Encoding]::ASCII.GetBytes("2.0`n"))
Add-ArEntry "control.tar.gz" ([System.IO.File]::ReadAllBytes((Join-Path $Stage "control.tar.gz")))
Add-ArEntry "data.tar.lzma" ([System.IO.File]::ReadAllBytes((Join-Path $Stage "data.tar.lzma")))
[System.IO.File]::WriteAllBytes($debPath, $arBytes.ToArray())

Write-Output "Created: $debPath"
Write-Output "Size: $((Get-Item $debPath).Length) bytes"
