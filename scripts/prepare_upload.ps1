$ErrorActionPreference = "Stop"
$Root = Split-Path $PSScriptRoot -Parent
$OutZip = Join-Path $Root "statescript-upload.zip"

if (Test-Path $OutZip) { Remove-Item $OutZip -Force }

$exclude = @(
    ".theos",
    "obj",
    "vendor\imgui",
    "packages\*.deb",
    "dist",
    "statescript-upload.zip"
)

$items = Get-ChildItem $Root -Force | Where-Object {
    $name = $_.Name
    if ($name -eq "vendor") {
        # include vendor folder structure but not imgui clone
        return $true
    }
    if ($name -eq "packages") { return $true }
    return $true
}

# Compress excluding heavy folders
$temp = Join-Path $env:TEMP "statescript_upload_staging"
if (Test-Path $temp) { Remove-Item $temp -Recurse -Force }
New-Item -ItemType Directory -Force -Path $temp | Out-Null

function Copy-Project($src, $dst) {
    Get-ChildItem $src -Force | ForEach-Object {
        if ($_.Name -eq ".theos" -or $_.Name -eq "obj") { return }
        if ($_.Name -eq "vendor") {
            $vDst = Join-Path $dst "vendor"
            New-Item -ItemType Directory -Force -Path $vDst | Out-Null
            return
        }
        if ($_.Name -eq "packages") {
            $pDst = Join-Path $dst "packages"
            New-Item -ItemType Directory -Force -Path $pDst | Out-Null
            Get-ChildItem $_.FullName -Filter "*.deb" | ForEach-Object { return }
            return
        }
        Copy-Item $_.FullName -Destination (Join-Path $dst $_.Name) -Recurse -Force
    }
}

Copy-Project $Root $temp
Compress-Archive -Path "$temp\*" -DestinationPath $OutZip -Force
Remove-Item $temp -Recurse -Force

Write-Output "Ready for GitHub upload:"
Write-Output $OutZip
Write-Output "Size: $((Get-Item $OutZip).Length) bytes"
Write-Output ""
Write-Output "Next: follow scripts\GITHUB_STEPS.txt"
