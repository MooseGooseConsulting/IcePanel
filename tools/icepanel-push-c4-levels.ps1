# Push C4 level diagrams (L1 context + L2 app + L3 component); remove legacy variants.
$ErrorActionPreference = 'Stop'
if (-not $env:ICE_PANEL_ADMIN) { throw 'ICE_PANEL_ADMIN not set' }

$base = 'https://api.icepanel.io/v1'
$hAuth = "Authorization: ApiKey $($env:ICE_PANEL_ADMIN)"
$lid = 'Efdez5uW6BfQjErrQ4Gx'
$vid = 'RlqaJB3HuwzYkFs3EcJW'
$repoRoot = Split-Path $PSScriptRoot -Parent
$diagramsDir = Join-Path $repoRoot 'imports\diagrams'

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

# Delete ALL existing diagrams
$list = Req 'GET' "/landscapes/$lid/versions/$vid/diagrams"
foreach ($d in ($list.json | ConvertFrom-Json).diagrams) {
    Write-Output "DELETE $($d.name)"
    Req 'DELETE' "/landscapes/$lid/versions/$vid/diagrams/$($d.id)" | Out-Null
}

# Push L1, L2, L3 in order
$files = Get-ChildItem -Path $diagramsDir -Filter 'portfolio-l*.json' | Sort-Object Name
foreach ($f in $files) {
    Write-Output "POST $($f.Name)..."
    $r = Req 'POST' "/landscapes/$lid/versions/$vid/diagrams" $f.FullName
    if ($r.status -ne 200) {
        Write-Output "  FAILED $($r.status): $($r.json)"
    } else {
        $did = ($r.json | ConvertFrom-Json).diagram.id
        $type = ($r.json | ConvertFrom-Json).diagram.type
        Write-Output "  OK id=$did type=$type"
    }
}

$list2 = Req 'GET' "/landscapes/$lid/versions/$vid/diagrams"
Write-Output "`nDiagrams:"
foreach ($d in ($list2.json | ConvertFrom-Json).diagrams) {
    Write-Output "  [$($d.type)] $($d.name)"
}
