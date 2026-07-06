# Push portfolio variant diagrams only
$ErrorActionPreference = 'Stop'
if (-not $env:ICE_PANEL_ADMIN) { throw 'ICE_PANEL_ADMIN not set' }

$base = 'https://api.icepanel.io/v1'
$hAuth = "Authorization: ApiKey $($env:ICE_PANEL_ADMIN)"
$lid = 'Efdez5uW6BfQjErrQ4Gx'
$vid = 'RlqaJB3HuwzYkFs3EcJW'
$dir = Join-Path (Split-Path $PSScriptRoot -Parent) 'imports\diagrams'
$reportsDir = Join-Path (Split-Path $PSScriptRoot -Parent) 'reports\diagrams'

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

$variants = @(
    'portfolio-variant-a-panorama',
    'portfolio-variant-b-github-hub',
    'portfolio-variant-c-layer-stack',
    'portfolio-variant-d-pr-review-core'
)

foreach ($name in $variants) {
    $path = Join-Path $dir "$name.json"
    if (-not (Test-Path $path)) { Write-Output "MISSING $name"; continue }
    Write-Output "POST $name..."
    $r = Req 'POST' "/landscapes/$lid/versions/$vid/diagrams" $path
    if ($r.status -ne 200) {
        Write-Output "  FAILED HTTP $($r.status)"
        Write-Output $r.json
        continue
    }
    $resp = $r.json | ConvertFrom-Json
    $did = $resp.diagram.id
    $objCount = @($resp.diagramContent.objects.PSObject.Properties).Count
    Write-Output "  OK diagramId=$did objects=$objCount"
}

$list = Req 'GET' "/landscapes/$lid/versions/$vid/diagrams"
$diagrams = ($list.json | ConvertFrom-Json).diagrams
Write-Output "`nTotal diagrams: $($diagrams.Count)"
foreach ($d in $diagrams) { Write-Output "  - $($d.name) ($($d.id))" }
