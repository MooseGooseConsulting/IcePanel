# IcePanel diagram push — POST full DiagramCreate bodies from imports/diagrams/
# Usage: doppler run -p dev-tools -c dev -- powershell -NoProfile -File .\tools\icepanel-push-diagrams.ps1 [slug|all]
$ErrorActionPreference = 'Stop'
if (-not $env:ICE_PANEL_ADMIN) { throw 'ICE_PANEL_ADMIN not set' }

$base = 'https://api.icepanel.io/v1'
$hAuth = "Authorization: ApiKey $($env:ICE_PANEL_ADMIN)"
$repoRoot = Split-Path $PSScriptRoot -Parent
$mapPath = Join-Path $repoRoot 'imports\landscapes-map.json'
$diagramsDir = Join-Path $repoRoot 'imports\diagrams'
$reportsDir = Join-Path $repoRoot 'reports\diagrams'

if (-not (Test-Path $mapPath)) { throw "Missing $mapPath" }

function Req([string]$method, [string]$path, [string]$bodyFile) {
    $url = "$base$path"
    $args = @('-s', '-w', "`nHTTP_STATUS:%{http_code}", $url, '-H', 'Accept: application/json', '-H', $hAuth)
    if ($method -ne 'GET') { $args += @('-X', $method, '-H', 'Content-Type: application/json') }
    if ($bodyFile) { $args += @('--data-binary', "@$bodyFile") }
    $resp = curl.exe @args
    $lines = $resp -split "`n"
    $status = ($lines | Where-Object { $_ -match '^HTTP_STATUS:' }) -replace 'HTTP_STATUS:', ''
    $json = ($lines | Where-Object { $_ -notmatch '^HTTP_STATUS:' }) -join "`n"
    return @{ status = [int]$status; json = $json }
}

function LatestVersion([string]$lid) {
    $r = Req 'GET' "/landscapes/$lid/versions"
    if ($r.status -ne 200) { throw "versions GET failed: $($r.status)" }
    $obj = $r.json | ConvertFrom-Json
    $latest = $obj.versions | Where-Object { $_.tags -contains 'latest' } | Select-Object -First 1
    if (-not $latest) { $latest = $obj.versions[0] }
    return $latest.id
}

function Export-DiagramPng([string]$lid, [string]$vid, [string]$diagramId, [string]$outPath) {
    $tmp = [System.IO.Path]::GetTempFileName() + '.json'
    @{ theme = 'light'; maxWidth = 2400 } | ConvertTo-Json -Compress | Set-Content $tmp -Encoding utf8
    $r = Req 'POST' "/landscapes/$lid/versions/$vid/diagrams/$diagramId/export/image" $tmp
    Remove-Item $tmp -Force
    if ($r.status -ne 200) { Write-Warning "export/image failed HTTP $($r.status)"; return $false }
    $exportId = ($r.json | ConvertFrom-Json).diagramExportImage.id
    if (-not $exportId) { return $false }
    for ($i = 0; $i -lt 30; $i++) {
        Start-Sleep -Seconds 2
        $poll = Req 'GET' "/landscapes/$lid/versions/$vid/diagrams/$diagramId/export/image/$exportId"
        if ($poll.status -ne 200) { continue }
        $job = $poll.json | ConvertFrom-Json
        $png = $job.diagramExportImage.fileUrls.png
        if ($png) {
            New-Item -ItemType Directory -Force -Path (Split-Path $outPath -Parent) | Out-Null
            curl.exe -s -o $outPath $png
            Write-Output "  PNG saved: $outPath"
            return $true
        }
    }
    Write-Warning "PNG poll timeout for diagram $diagramId"
    return $false
}

function Push-Slug([string]$slug, $entry) {
    $lid = $entry.landscapeId
    $vid = if ($entry.versionId) { $entry.versionId } else { LatestVersion $lid }
    Write-Output "`n========== $slug (landscapeId=$lid) =========="

    $pattern = Join-Path $diagramsDir "$slug-*.json"
    $files = Get-ChildItem -Path $pattern -ErrorAction SilentlyContinue | Where-Object { $_.Name -notmatch '-flows\.json$' }
    if (-not $files -or $files.Count -eq 0) {
        Write-Output "  SKIP: no diagram files matching $pattern"
        return @{ slug = $slug; pushed = 0; skipped = $true }
    }

    $existing = Req 'GET' "/landscapes/$lid/versions/$vid/diagrams"
    $existingCount = 0
    if ($existing.status -eq 200) {
        $existingCount = @(($existing.json | ConvertFrom-Json).diagrams).Count
    }
    Write-Output "  existing diagrams: $existingCount"

    $pushed = 0
    $firstDiagramId = $null
    foreach ($f in $files) {
        Write-Output "  POST $($f.Name)..."
        $r = Req 'POST' "/landscapes/$lid/versions/$vid/diagrams" $f.FullName
        if ($r.status -ne 200) {
            Write-Output "  FAILED HTTP $($r.status): $($r.json)"
            continue
        }
        $resp = $r.json | ConvertFrom-Json
        $did = $resp.diagram.id
        $objCount = @($resp.diagramContent.objects.PSObject.Properties).Count
        Write-Output "  OK diagramId=$did objects=$objCount"
        if (-not $firstDiagramId) { $firstDiagramId = $did }
        $pushed++
    }

    if ($firstDiagramId) {
        $pngPath = Join-Path $reportsDir "$slug-context.png"
        Export-DiagramPng $lid $vid $firstDiagramId $pngPath | Out-Null
    }

    Write-Output "  done pushed=$pushed"
    return
}

$target = $args[0]
if (-not $target) { throw 'Usage: icepanel-push-diagrams.ps1 <slug|all>' }

$map = Get-Content -Raw $mapPath | ConvertFrom-Json

if ($target -eq 'all') {
    foreach ($prop in $map.PSObject.Properties) {
        Push-Slug $prop.Name $prop.Value | Out-Null
    }
} else {
    if (-not $map.$target) { throw "Unknown slug: $target" }
    Push-Slug $target $map.$target | Out-Null
}
