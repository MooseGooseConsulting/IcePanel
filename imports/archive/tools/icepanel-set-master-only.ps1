# Replace portfolio diagrams with ONE master map; delete variant canvases.
$ErrorActionPreference = 'Stop'
if (-not $env:ICE_PANEL_ADMIN) { throw 'ICE_PANEL_ADMIN not set' }

$base = 'https://api.icepanel.io/v1'
$hAuth = "Authorization: ApiKey $($env:ICE_PANEL_ADMIN)"
$lid = 'Efdez5uW6BfQjErrQ4Gx'
$vid = 'RlqaJB3HuwzYkFs3EcJW'
$repoRoot = Split-Path $PSScriptRoot -Parent

function Req([string]$method, [string]$path, [string]$bodyFile) {
    $url = "$base$path"
    $args = @('-s', '-w', "`nHTTP_STATUS:%{http_code}", $url, '-H', 'Accept: application/json', '-H', $hAuth)
    if ($method -ne 'GET') { $args += @('-X', $method) }
    if ($bodyFile) { $args += @('-H', 'Content-Type: application/json', '--data-binary', "@$bodyFile") }
    $resp = curl.exe @args
    $lines = $resp -split "`n"
    $status = ($lines | Where-Object { $_ -match '^HTTP_STATUS:' }) -replace 'HTTP_STATUS:', ''
    $json = ($lines | Where-Object { $_ -notmatch '^HTTP_STATUS:' }) -join "`n"
    return @{ status = [int]$status; json = $json }
}

$list = Req 'GET' "/landscapes/$lid/versions/$vid/diagrams"
$diagrams = ($list.json | ConvertFrom-Json).diagrams
Write-Output "Existing diagrams: $($diagrams.Count)"

foreach ($d in $diagrams) {
    if ($d.handleId -eq 'portfolio-master') {
        Write-Output "DELETE existing master $($d.id)"
        Req 'DELETE' "/landscapes/$lid/versions/$vid/diagrams/$($d.id)" | Out-Null
    }
}

# Remove all non-master diagrams (variants + old context)
foreach ($d in $diagrams) {
    if ($d.handleId -eq 'portfolio-master') { continue }
    Write-Output "DELETE $($d.name) ($($d.id))"
    $r = Req 'DELETE' "/landscapes/$lid/versions/$vid/diagrams/$($d.id)"
    Write-Output "  HTTP $($r.status)"
}

$masterPath = Join-Path $repoRoot 'imports\diagrams\portfolio-master.json'
Write-Output "POST portfolio-master..."
$r = Req 'POST' "/landscapes/$lid/versions/$vid/diagrams" $masterPath
Write-Output "HTTP $($r.status)"
if ($r.status -ne 200) { Write-Output $r.json; exit 1 }
$masterId = ($r.json | ConvertFrom-Json).diagram.id
Write-Output "Master diagramId=$masterId"

$list2 = Req 'GET' "/landscapes/$lid/versions/$vid/diagrams"
$diagrams2 = ($list2.json | ConvertFrom-Json).diagrams
foreach ($d in $diagrams2) {
    if ($d.id -eq $masterId) { continue }
    Write-Output "DELETE extra $($d.name) ($($d.id))"
    Req 'DELETE' "/landscapes/$lid/versions/$vid/diagrams/$($d.id)" | Out-Null
}
