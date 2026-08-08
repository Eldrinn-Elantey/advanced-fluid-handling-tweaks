#requires -Version 5
# Builds build\<name>_<version>.zip. Pass -Install to also copy it into the local mods folder.
param(
    [switch]$Install,
    [string]$ModsDir = "$env:APPDATA\Factorio\mods"
)

$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

$info = Get-Content info.json -Raw | ConvertFrom-Json
$folder = "$($info.name)_$($info.version)"

# Everything the mod needs at runtime; anything else in the repo stays out of the zip.
$content = @('info.json', 'data-final-fixes.lua', 'locale', 'changelog.txt', 'README.md', 'LICENSE') |
    Where-Object { Test-Path $_ }

$staging = Join-Path 'build' $folder
if (Test-Path 'build') { Remove-Item 'build' -Recurse -Force }
New-Item -ItemType Directory -Path $staging -Force | Out-Null
Copy-Item $content -Destination $staging -Recurse

$zip = Join-Path 'build' "$folder.zip"
Compress-Archive -Path $staging -DestinationPath $zip -Force
Remove-Item $staging -Recurse -Force

Write-Host "Built $zip"

if ($Install) {
    Copy-Item $zip -Destination $ModsDir -Force
    Write-Host "Installed to $ModsDir"
}
