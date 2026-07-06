# Debug why landscapes may not appear in IcePanel UI.
$ErrorActionPreference = 'Stop'
if (-not $env:ICE_PANEL_ADMIN) { throw 'ICE_PANEL_ADMIN not set' }

$base = 'https://api.icepanel.io/v1'
$hAuth = "Authorization: ApiKey $($env:ICE_PANEL_ADMIN)"
$hAccept = 'Accept: application/json'

function Req([string]$path, [string]$method = 'GET', [string]$body = $null) {
    $args = @('-s', '-w', "`nHTTP_STATUS:%{http_code}", "$base$path", '-H', $hAccept, '-H', $hAuth)
    if ($method -ne 'GET') { $args += @('-X', $method) }
    if ($body) { $args += @('-H', 'Content-Type: application/json', '-d', $body) }
    $resp = curl.exe @args
    $lines = $resp -split "`n"
    $statusLine = ($lines | Where-Object { $_ -match '^HTTP_STATUS:' }) -replace 'HTTP_STATUS:', ''
    $json = ($lines | Where-Object { $_ -notmatch '^HTTP_STATUS:' }) -join "`n"
    return @{ status = [int]$statusLine; json = $json }
}

Write-Output '=== Organizations visible to this API key ==='
$orgs = (Req '/organizations').json | ConvertFrom-Json
foreach ($o in $orgs.organizations) {
    Write-Output ("  - {0} (id={1}, plan={2}, status={3})" -f $o.name, $o.id, $o.plan.id, $o.plan.status)
}

Write-Output ''
Write-Output '=== All landscapes ==='
$lands = (Req '/organizations/8kpJ4KngNPCU2sbVFkgV/landscapes').json | ConvertFrom-Json
foreach ($l in $lands.landscapes) {
    $verResp = Req "/landscapes/$($l.id)/versions"
    $vers = ($verResp.json | ConvertFrom-Json).versions
    $latest = $vers | Where-Object { $_.tags -contains 'latest' } | Select-Object -First 1
    $objCount = 0
    if ($latest) {
        $objResp = Req "/landscapes/$($l.id)/versions/$($latest.id)/model/objects"
        $objCount = (($objResp.json | ConvertFrom-Json).modelObjects).Count
    }
    Write-Output ("  - {0}" -f $l.name)
    Write-Output ("    id={0}  objects={1}  appUrl=https://app.icepanel.io/landscapes/{0}/versions/latest" -f $l.id, $objCount)
}

Write-Output ''
Write-Output '=== Default signup landscape (Patrick''s landscape) ==='
$defaultId = 'ZNE1oCXATJ74UshQrw5N'
$verResp = Req "/landscapes/$defaultId/versions"
$vers = ($verResp.json | ConvertFrom-Json).versions
$latest = $vers | Where-Object { $_.tags -contains 'latest' } | Select-Object -First 1
$objResp = Req "/landscapes/$defaultId/versions/$($latest.id)/model/objects"
$objs = (($objResp.json | ConvertFrom-Json).modelObjects)
Write-Output ("  objects={0} (this is likely what you see when you open IcePanel)" -f $objs.Count)
if ($objs.Count -eq 0) { Write-Output '  ^ EMPTY - explains seeing nothing in UI if you stay on default landscape' }

Write-Output ''
Write-Output '=== Share link status for Portfolio ==='
$lid = 'Efdez5uW6BfQjErrQ4Gx'
$vid = 'RlqaJB3HuwzYkFs3EcJW'
$sl = Req "/landscapes/$lid/versions/$vid/share-link"
Write-Output ("  GET share-link HTTP {0}" -f $sl.status)
Write-Output $sl.json

Write-Output ''
Write-Output '=== API key / identity endpoints ==='
foreach ($path in @('/me', '/users', '/api-keys', '/organizations/8kpJ4KngNPCU2sbVFkgV/api-keys')) {
    $r = Req $path
    Write-Output ("  GET {0} -> HTTP {1}" -f $path, $r.status)
    if ($r.status -lt 500) { Write-Output ("  {0}" -f $r.json) }
}

Write-Output ''
Write-Output '=== Portfolio: diagrams (empty canvas = looks like nothing in UI) ==='
$diag = Req '/landscapes/Efdez5uW6BfQjErrQ4Gx/versions/RlqaJB3HuwzYkFs3EcJW/diagrams'
Write-Output ("  HTTP {0}" -f $diag.status)
$diagObj = $diag.json | ConvertFrom-Json
Write-Output ("  diagram count={0}" -f @($diagObj.diagrams).Count)
if (@($diagObj.diagrams).Count -eq 0) {
    Write-Output '  ^ NO DIAGRAMS - IcePanel canvas will look blank even though model objects exist in the data model'
}

Write-Output ''
Write-Output '=== Portfolio: domains ==='
$dom = Req '/landscapes/Efdez5uW6BfQjErrQ4Gx/versions/RlqaJB3HuwzYkFs3EcJW/domains'
($dom.json | ConvertFrom-Json).domains | ForEach-Object { Write-Output ("  - {0} (id={1})" -f $_.name, $_.id) }

Write-Output ''
Write-Output '=== Org members (who can see this in browser?) ==='
$mem = Req '/organizations/8kpJ4KngNPCU2sbVFkgV/members'
Write-Output ("  HTTP {0}" -f $mem.status)
Write-Output $mem.json

Write-Output ''
Write-Output '=== Default landscape sole object ==='
$objResp2 = Req "/landscapes/$defaultId/versions/$($latest.id)/model/objects"
($objResp2.json | ConvertFrom-Json).modelObjects | ForEach-Object { Write-Output ("  - {0} ({1})" -f $_.name, $_.type) }

Write-Output ''
Write-Output '=== Share link with handle (full defaultUrl) ==='
Write-Output '  https://s.icepanel.io/BKWC9YAovn1qa9/8wHl'

Write-Output ''
Write-Output '=== Direct app links (log into same account as API key) ==='
Write-Output '  Portfolio:  https://app.icepanel.io/landscapes/Efdez5uW6BfQjErrQ4Gx/versions/latest'
Write-Output '  K8s:        https://app.icepanel.io/landscapes/JyXDiYoXVfa7Xz3AnEfY/versions/latest'
Write-Output '  Org picker: https://app.icepanel.io/'
