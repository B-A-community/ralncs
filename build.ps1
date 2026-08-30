# Собирает dist\RALNCS_<version>.rbz из src\.
# Пакуем через .NET ZipFile: Compress-Archive в PS 5.1 пишет пути с "\",
# что ломает распаковку в некоторых инсталляторах.
$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$src  = Join-Path $PSScriptRoot "src"
$dist = Join-Path $PSScriptRoot "dist"
New-Item -ItemType Directory -Force $dist | Out-Null

$version = (Select-String -Path (Join-Path $src "ralncs.rb") -Pattern "ex\.version\s*=\s*'([^']+)'").Matches[0].Groups[1].Value
$rbz = Join-Path $dist "RALNCS_$version.rbz"
Remove-Item $rbz -ErrorAction SilentlyContinue

$zip = [System.IO.Compression.ZipFile]::Open($rbz, [System.IO.Compression.ZipArchiveMode]::Create)
try {
  Get-ChildItem $src -Recurse -File | ForEach-Object {
    $rel = $_.FullName.Substring($src.Length + 1) -replace '\\', '/'
    [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $_.FullName, $rel) | Out-Null
  }
} finally {
  $zip.Dispose()
}
Write-Host "Готово: $rbz"
