# Собирает dist\RALNCS-<version>-rus.rbz и dist\RALNCS-<version>-eng.rbz из src\.
#   .\build.ps1            — оба пакета
#   .\build.ps1 -Lang en   — только английский
# Языковой пакет — тот же исходник, в копии подменяется строка LANG
# в src\ralncs\lang.rb (Ruby) и src\ralncs\html\i18n.js (окна).
# Пакуем через .NET ZipFile: Compress-Archive в PS 5.1 пишет пути с "\",
# что ломает распаковку в некоторых инсталляторах.
param([ValidateSet('ru', 'en', 'all')][string]$Lang = 'all')
$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$src  = Join-Path $PSScriptRoot "src"
$dist = Join-Path $PSScriptRoot "dist"
New-Item -ItemType Directory -Force $dist | Out-Null

$version = (Select-String -Path (Join-Path $src "ralncs.rb") -Pattern "ex\.version\s*=\s*'([^']+)'").Matches[0].Groups[1].Value
$suffix = @{ ru = 'rus'; en = 'eng' }
$langs = if ($Lang -eq 'all') { @('ru', 'en') } else { @($Lang) }
$utf8 = New-Object System.Text.UTF8Encoding $false

foreach ($l in $langs) {
  $stage = Join-Path $env:TEMP ("ralncs_build_" + $l)
  Remove-Item $stage -Recurse -Force -ErrorAction SilentlyContinue
  Copy-Item $src $stage -Recurse

  foreach ($f in @('ralncs\lang.rb', 'ralncs\html\i18n.js')) {
    $p = Join-Path $stage $f
    $text = [System.IO.File]::ReadAllText($p, $utf8)
    $patched = $text -replace "LANG = '[a-z]{2}'", "LANG = '$l'"
    if ($patched -eq $text -and $l -ne 'ru') { throw "Не нашёл строку LANG в $f" }
    [System.IO.File]::WriteAllText($p, $patched, $utf8)
  }

  $rbz = Join-Path $dist ("RALNCS-{0}-{1}.rbz" -f $version, $suffix[$l])
  Remove-Item $rbz -ErrorAction SilentlyContinue
  $zip = [System.IO.Compression.ZipFile]::Open($rbz, [System.IO.Compression.ZipArchiveMode]::Create)
  try {
    Get-ChildItem $stage -Recurse -File | ForEach-Object {
      $rel = $_.FullName.Substring($stage.Length + 1) -replace '\\', '/'
      [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $_.FullName, $rel) | Out-Null
    }
  } finally {
    $zip.Dispose()
  }
  Remove-Item $stage -Recurse -Force
  Write-Host "Готово: $rbz"
}
