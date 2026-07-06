# IcePanel layout scaffold — fetch model and emit DiagramCreate JSON
# Usage: doppler run -p dev-tools -c dev -- powershell -NoProfile -File .\tools\icepanel-layout.ps1 <slug> [context|app]
$ErrorActionPreference = 'Stop'
if (-not $env:ICE_PANEL_ADMIN) { throw 'ICE_PANEL_ADMIN not set' }

$base = 'https://api.icepanel.io/v1'
$hAuth = "Authorization: ApiKey $($env:ICE_PANEL_ADMIN)"
$repoRoot = Split-Path $PSScriptRoot -Parent
$mapPath = Join-Path $repoRoot 'imports\landscapes-map.json'
$outDir = Join-Path $repoRoot 'imports\diagrams'

$ORIGIN_X = 80; $COL_W = 320; $ROW_H = 160; $BOX_W = 280; $BOX_H = 120

function Req([string]$path) {
    $url = "$base$path"
    $resp = curl.exe -s -w "`nHTTP_STATUS:%{http_code}" $url -H 'Accept: application/json' -H $hAuth
    $lines = $resp -split "`n"
    $status = ($lines | Where-Object { $_ -match '^HTTP_STATUS:' }) -replace 'HTTP_STATUS:', ''
    $json = ($lines | Where-Object { $_ -notmatch '^HTTP_STATUS:' }) -join "`n"
    return @{ status = [int]$status; json = $json }
}

$slug = $args[0]
$mode = if ($args[1]) { $args[1] } else { 'context' }
if (-not $slug) { throw 'Usage: icepanel-layout.ps1 <slug> [context|app]' }

$map = Get-Content -Raw $mapPath | ConvertFrom-Json
$entry = $map.$slug
if (-not $entry) { throw "Unknown slug: $slug" }

$lid = $entry.landscapeId
$vid = $entry.versionId

$objR = Req "/landscapes/$lid/versions/$vid/model/objects"
$connR = Req "/landscapes/$lid/versions/$vid/model/connections"
if ($objR.status -ne 200) { throw "objects GET failed: $($objR.status)" }

$objects = ($objR.json | ConvertFrom-Json).modelObjects
$connections = if ($connR.status -eq 200) { ($connR.json | ConvertFrom-Json).modelConnections } else { @() }

$domain = $objects | Where-Object { $_.type -eq 'domain' -or $_.type -eq 'root' } | Select-Object -First 1
if (-not $domain) { throw 'No domain/root object found' }

$actors = @($objects | Where-Object { $_.type -eq 'actor' })
$systems = @($objects | Where-Object { $_.type -eq 'system' -and -not $_.external })
$externals = @($objects | Where-Object { $_.type -eq 'system' -and $_.external })

$diagramObjects = @{}
$idx = 0

foreach ($a in $actors) {
    $key = "do-$idx"
    $diagramObjects[$key] = @{
        id = $key; modelId = $a.id; type = 'actor'; shape = 'box'
        x = $ORIGIN_X; y = 80 + ($idx * $ROW_H); width = 200; height = 100
    }
    $idx++
}

$idx = 0
foreach ($s in $systems) {
    $key = "do-sys-$idx"
    $diagramObjects[$key] = @{
        id = $key; modelId = $s.id; type = 'system'; shape = 'box'
        x = $ORIGIN_X + $COL_W; y = 80 + ($idx * $ROW_H); width = $BOX_W; height = $BOX_H
    }
    $idx++
}

$idx = 0
foreach ($e in $externals) {
    $key = "do-ext-$idx"
    $diagramObjects[$key] = @{
        id = $key; modelId = $e.id; type = 'system'; shape = 'box'
        x = $ORIGIN_X + (2 * $COL_W); y = 80 + ($idx * $ROW_H); width = $BOX_W; height = $BOX_H
    }
    $idx++
}

# Map model id -> diagram object key
$keyByModel = @{}
foreach ($prop in $diagramObjects.GetEnumerator()) {
    $keyByModel[$prop.Value.modelId] = $prop.Key
}

$diagramConnections = @{}
$ci = 0
foreach ($c in $connections) {
    $oKey = $keyByModel[$c.originId]
    $tKey = $keyByModel[$c.targetId]
    if (-not $oKey -or -not $tKey) { continue }
    $ck = "dc-$ci"
    $diagramConnections[$ck] = @{
        id = $ck; modelId = $c.id; originId = $oKey; targetId = $tKey
        lineShape = 'curved'; originConnector = 'right-middle'; targetConnector = 'left-middle'
        labelPosition = 0.5; points = @()
    }
    $ci++
}

$body = @{
    name = "$slug - Context"
    type = 'context-diagram'
    modelId = $domain.id
    index = 0
    pinned = $true
    handleId = "$slug-context"
    objects = $diagramObjects
    connections = $diagramConnections
    comments = @{}
}

New-Item -ItemType Directory -Force -Path $outDir | Out-Null
$outFile = Join-Path $outDir "$slug-context.json"
$body | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $outFile -Encoding utf8
Write-Output "Wrote $outFile ($($diagramObjects.Count) objects, $($diagramConnections.Count) connections)"
