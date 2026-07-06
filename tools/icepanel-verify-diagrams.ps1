# Quick diagram count verify for all landscapes in map
$ErrorActionPreference = 'Stop'
if (-not $env:ICE_PANEL_ADMIN) { throw 'ICE_PANEL_ADMIN not set' }
$base = 'https://api.icepanel.io/v1'
$hAuth = "Authorization: ApiKey $($env:ICE_PANEL_ADMIN)"
$repoRoot = Split-Path $PSScriptRoot -Parent
$map = Get-Content (Join-Path $repoRoot 'imports\landscapes-map.json') -Raw | ConvertFrom-Json

foreach ($prop in $map.PSObject.Properties) {
    $slug = $prop.Name
    $lid = $prop.Value.landscapeId
    $vid = $prop.Value.versionId
    $resp = curl.exe -s -H 'Accept: application/json' -H $hAuth "$base/landscapes/$lid/versions/$vid/diagrams"
    $count = @(($resp | ConvertFrom-Json).diagrams).Count
    Write-Output "$slug diagrams=$count landscapeId=$lid"
}

$pngDir = Join-Path $repoRoot 'reports\diagrams'
if (Test-Path $pngDir) {
    Write-Output ''
    Write-Output 'PNG files:'
    Get-ChildItem $pngDir | ForEach-Object { Write-Output $_.FullName }
}
