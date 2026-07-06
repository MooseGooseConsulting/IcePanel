# Dump model objects + connections as name->id map for diagram authors
# Usage: doppler run -p dev-tools -c dev -- powershell -NoProfile -File .\tools\icepanel-dump-model.ps1 portfolio
$ErrorActionPreference = 'Stop'
if (-not $env:ICE_PANEL_ADMIN) { throw 'ICE_PANEL_ADMIN not set' }

$base = 'https://api.icepanel.io/v1'
$hAuth = "Authorization: ApiKey $($env:ICE_PANEL_ADMIN)"
$repoRoot = Split-Path $PSScriptRoot -Parent
$mapPath = Join-Path $repoRoot 'imports\landscapes-map.json'
$slug = $args[0]
if (-not $slug) { throw 'Usage: icepanel-dump-model.ps1 <slug>' }

$map = Get-Content -Raw $mapPath | ConvertFrom-Json
$entry = $map.$slug
$lid = $entry.landscapeId
$vid = $entry.versionId

function Req([string]$path) {
    $url = "$base$path"
    $resp = curl.exe -s -w "`nHTTP_STATUS:%{http_code}" $url -H 'Accept: application/json' -H $hAuth
    $lines = $resp -split "`n"
    $status = ($lines | Where-Object { $_ -match '^HTTP_STATUS:' }) -replace 'HTTP_STATUS:', ''
    $json = ($lines | Where-Object { $_ -notmatch '^HTTP_STATUS:' }) -join "`n"
    return @{ status = [int]$status; json = $json }
}

$objR = Req "/landscapes/$lid/versions/$vid/model/objects"
$connR = Req "/landscapes/$lid/versions/$vid/model/connections"
if ($objR.status -ne 200) { throw "objects GET failed: $($objR.status) $($objR.json)" }

$objects = ($objR.json | ConvertFrom-Json).modelObjects
$connections = if ($connR.status -eq 200) { ($connR.json | ConvertFrom-Json).modelConnections } else { @() }

$domain = $objects | Where-Object { $_.type -eq 'domain' -or $_.type -eq 'root' } | Select-Object -First 1

$out = @{
    slug = $slug
    landscapeId = $lid
    versionId = $vid
    domainId = $domain.id
    domainName = $domain.name
    objectCount = $objects.Count
    connectionCount = $connections.Count
    objects = @($objects | ForEach-Object {
        @{
            id = $_.id
            name = $_.name
            type = $_.type
            external = $_.external
            status = $_.status
            parentId = $_.parentId
            importOriginalId = $_.labels.'import-original-id'
        }
    })
    connections = @($connections | ForEach-Object {
        @{
            id = $_.id
            name = $_.name
            originId = $_.originId
            targetId = $_.targetId
            originName = ($objects | Where-Object { $_.id -eq $_.originId } | Select-Object -First 1).name
            targetName = ($objects | Where-Object { $_.id -eq $_.targetId } | Select-Object -First 1).name
        }
    })
}

$reportsDir = Join-Path $repoRoot 'reports'
New-Item -ItemType Directory -Force -Path $reportsDir | Out-Null
$outPath = Join-Path $reportsDir "$slug-model-map.json"
$out | ConvertTo-Json -Depth 6 | Set-Content $outPath -Encoding utf8
Write-Output "Wrote $outPath ($($objects.Count) objects, $($connections.Count) connections)"
