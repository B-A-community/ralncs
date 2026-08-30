# Generates src/ralncs/data/*.json from public datasets:
#   RAL Classic: https://gist.github.com/lunohodov/1995178 (ral_classic.csv)
#   NCS 1950:    https://github.com/5monkeys/python-ncs (collection 263 = NCS S standard)
# Expects the raw CSVs in $env:TEMP (ral_classic.csv, ncs_collections.csv, ncs_colors.csv);
# downloads them if missing.

$ErrorActionPreference = "Stop"
$dataDir = Join-Path $PSScriptRoot "..\src\ralncs\data"
New-Item -ItemType Directory -Force $dataDir | Out-Null

$ralCsv = Join-Path $env:TEMP "ral_classic.csv"
$colCsv = Join-Path $env:TEMP "ncs_collections.csv"
$clrCsv = Join-Path $env:TEMP "ncs_colors.csv"

if (-not (Test-Path $ralCsv)) {
  Invoke-WebRequest -Uri "https://gist.githubusercontent.com/lunohodov/1995178/raw/cba796219888052065c4735df093ab2a664889b0/ral_classic.csv" -OutFile $ralCsv
}
if (-not (Test-Path $colCsv)) {
  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/5monkeys/python-ncs/master/data/collections.csv" -OutFile $colCsv
}
if (-not (Test-Path $clrCsv)) {
  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/5monkeys/python-ncs/master/data/colors.csv" -OutFile $clrCsv
}

# --- RAL Classic ---
$ral = Import-Csv -Path $ralCsv -Encoding UTF8 | ForEach-Object {
  [ordered]@{ code = $_.RAL; hex = $_.HEX; name = $_.English }
}
$ralJson = ($ral | ForEach-Object {
  '  {{"code":"{0}","hex":"{1}","name":"{2}"}}' -f $_.code, $_.hex, ($_.name -replace '"','\"')
}) -join ",`n"
[System.IO.File]::WriteAllText((Join-Path $dataDir "ral_classic.json"), "[`n$ralJson`n]`n", (New-Object System.Text.UTF8Encoding $false))
Write-Host ("RAL Classic: {0} colors" -f $ral.Count)

# --- NCS 1950 (collection 263) ---
$rgbById = @{}
Import-Csv -Path $clrCsv | ForEach-Object { $rgbById[$_.ColorID] = $_.RGB }

$ncs = Import-Csv -Path $colCsv | Where-Object { $_.ColorCollectionID -eq "263" } | ForEach-Object {
  $hex = $rgbById[$_.ColorID]
  if ($hex) { [ordered]@{ code = ("NCS " + $_.ColorName); hex = ("#" + $hex) } }
} | Where-Object { $_ }
$ncsJson = ($ncs | ForEach-Object {
  '  {{"code":"{0}","hex":"{1}"}}' -f $_.code, $_.hex
}) -join ",`n"
[System.IO.File]::WriteAllText((Join-Path $dataDir "ncs_1950.json"), "[`n$ncsJson`n]`n", (New-Object System.Text.UTF8Encoding $false))
Write-Host ("NCS 1950: {0} colors" -f $ncs.Count)
