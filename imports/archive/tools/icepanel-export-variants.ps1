# Export PNG for each portfolio variant diagram
$ErrorActionPreference = 'Stop'
if (-not $env:ICE_PANEL_ADMIN) { throw 'ICE_PANEL_ADMIN not set' }

$base = 'https://api.icepanel.io/v1'
$hAuth = "Authorization: ApiKey $($env:ICE_PANEL_ADMIN)"
$lid = 'Efdez5uW6BfQjErrQ4Gx'
$vid = 'RlqaJB3HuwzYkFs3EcJW'
$reportsDir = Join-Path (Split-Path $PSScriptRoot -Parent) 'reports\diagrams'
New-Item -ItemType Directory -Force -Path $reportsDir | Out-Null

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

$handles = @{
    'portfolio-master' = 'master'
    'portfolio-variant-a-panorama' = 'a'
    'portfolio-variant-b-github-hub' = 'b'
    'portfolio-variant-c-layer-stack' = 'c'
    'portfolio-variant-d-pr-review-core' = 'd'
}

$list = Req 'GET' "/landscapes/$lid/versions/$vid/diagrams"
$diagrams = ($list.json | ConvertFrom-Json).diagrams

foreach ($d in $diagrams) {
    $hid = $d.handleId
    $suffix = $handles[$hid]
    if (-not $suffix) { continue }
    $outPath = Join-Path $reportsDir "portfolio-variant-$suffix.png"
    Write-Output "Export $($d.name) -> $outPath"
    $tmp = [System.IO.Path]::GetTempFileName() + '.json'
    @{ theme = 'light'; maxWidth = 3200 } | ConvertTo-Json -Compress | Set-Content $tmp -Encoding utf8
    $r = Req 'POST' "/landscapes/$lid/versions/$vid/diagrams/$($d.id)/export/image" $tmp
    Remove-Item $tmp -Force
    if ($r.status -ne 200) { Write-Output "  export failed $($r.status)"; continue }
    $exportId = ($r.json | ConvertFrom-Json).diagramExportImage.id
    for ($i = 0; $i -lt 30; $i++) {
        Start-Sleep -Seconds 2
        $poll = Req 'GET' "/landscapes/$lid/versions/$vid/diagrams/$($d.id)/export/image/$exportId"
        if ($poll.status -ne 200) { continue }
        $png = ($poll.json | ConvertFrom-Json).diagramExportImage.fileUrls.png
        if ($png) {
            curl.exe -s -o $outPath $png
            Write-Output "  saved $outPath"
            break
        }
    }
}

Write-Output "Share: https://s.icepanel.io/BKWC9YAovn1qa9"
Write-Output "Editor: https://app.icepanel.io/landscapes/$lid/versions/latest"
