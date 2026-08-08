#requires -Version 5
# Builds build\<name>_<version>.zip. Pass -Install to also copy it into the local mods folder.
param(
    [string]$Version,
    [switch]$Install,
    [string]$ModsDir = "$env:APPDATA\Factorio\mods"
)

$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

$info = Get-Content info.json -Raw | ConvertFrom-Json

# The git tag is what a release is named after, so it decides the version. Falling back to
# the last tag reachable from HEAD keeps local builds working between releases, and to the
# committed value when there is no tag or no git at all.
if (-not $Version) { $Version = $env:GITHUB_REF_NAME }
if (-not $Version) { $Version = git describe --tags --abbrev=0 2>$null }
if (-not $Version) { $Version = $info.version }
if ($Version -notmatch '^\d+\.\d+\.\d+$') { throw "Version '$Version' is not <major>.<minor>.<patch>" }

$info.version = $Version
$folder = "$($info.name)_$Version"

# Everything the mod needs at runtime; anything else in the repo stays out of the zip.
$content = @('info.json', 'data-final-fixes.lua', 'locale', 'changelog.txt', 'README.md', 'LICENSE') |
    Where-Object { Test-Path $_ }

$staging = Join-Path 'build' $folder
if (Test-Path 'build') { Remove-Item 'build' -Recurse -Force }
New-Item -ItemType Directory -Path $staging -Force | Out-Null
Copy-Item $content -Destination $staging -Recurse
$info | ConvertTo-Json -Depth 10 | Set-Content (Join-Path $staging 'info.json')

$zip = Join-Path 'build' "$folder.zip"
Compress-Archive -Path $staging -DestinationPath $zip -Force
Remove-Item $staging -Recurse -Force

Write-Host "Built $zip"

if ($Install) {
    Copy-Item $zip -Destination $ModsDir -Force
    Write-Host "Installed to $ModsDir"
}
