# IcePanel MCP-equivalent capability demo — exercises every read/write operation via REST
# on the Scratch Demo landscape, logging results for the showcase report.
# Run via: doppler run -p dev-tools -c dev -- powershell -NoProfile -File .\tools\icepanel-demo.ps1
$ErrorActionPreference = 'SilentlyContinue'
if (-not $env:ICE_PANEL_ADMIN) { Write-Output 'ICE_PANEL_ADMIN=missing'; exit 2 }

$base = 'https://api.icepanel.io/v1'
$org = '8kpJ4KngNPCU2sbVFkgV'
$hAuth = "Authorization: ApiKey $($env:ICE_PANEL_ADMIN)"
$hAccept = 'Accept: application/json'
$hJson = 'Content-Type: application/json'

# Scratch Demo landscape + version (created during Phase 0 validation)
$demoLid = 'qkdcU3yoajAeWB2ruOh2'
$demoVid = '2rHL1EjsFMCULIh9AyIE'
$demoSystemId = 'WiVqr78CzBeyTgrN12SF'   # Demo System
$demoActorId  = 'd6dqngd8uJTiptQx2OP9'   # Operator
$demoAppId    = 'v4rDwujEtljOFr5HsKwq'   # Demo App

function NewTmp() { $p = Join-Path $env:TEMP ("ice-" + [guid]::NewGuid().ToString('N') + ".json"); New-Item -ItemType File -Path $p -Force | Out-Null; return $p }
function WriteJson($path, $obj) { $obj | ConvertTo-Json -Compress -Depth 8 | Set-Content -LiteralPath $path -Encoding utf8 }
function Req([string]$method, [string]$path, [string]$bodyFile) {
    $url = "$base$path"
    if ($method -eq 'GET') { return curl.exe -s -w "`nHTTP_STATUS:%{http_code}" $url -H $hAccept -H $hAuth }
    $cargs = @('-s','-w',"`nHTTP_STATUS:%{http_code}",'-X',$method,$url,'-H',$hAccept,'-H',$hAuth,'-H',$hJson)
    if ($bodyFile) { $cargs += '--data-binary',"@$bodyFile" }
    return & curl.exe @cargs
}
function SplitResp($resp) { $lines = $resp -split "`n"; return @{ body = ($lines[0..($lines.Length-2)] -join "`n"); status = $lines[-1] } }
function Section($t) { Write-Output "`n--- $t ---" }
function Show($r) { Write-Output ("HTTP " + $r.status); Write-Output $r.body }

$out = @()

# ============ READ DEMOS ============
Section 'READ 1: List landscapes'
$r = SplitResp (Req 'GET' "/organizations/$org/landscapes")
$lcount = ($r.body | ConvertFrom-Json).landscapes.Count
Write-Output "landscapes count=$lcount (HTTP $($r.status))"

Section 'READ 2: List domains'
$r = SplitResp (Req 'GET' "/landscapes/$demoLid/versions/$demoVid/domains")
$dcount = ($r.body | ConvertFrom-Json).domains.Count
Write-Output "domains count=$dcount (HTTP $($r.status))"

Section 'READ 3: List tag groups + tags'
$r = SplitResp (Req 'GET' "/landscapes/$demoLid/versions/$demoVid/tag-groups")
$tgcount = ($r.body | ConvertFrom-Json).tagGroups.Count
$r2 = SplitResp (Req 'GET' "/landscapes/$demoLid/versions/$demoVid/tags")
$tcount = ($r2.body | ConvertFrom-Json).tags.Count
Write-Output "tagGroups=$tgcount tags=$tcount (HTTP $($r.status)/$($r2.status))"

Section 'READ 4: List model objects'
$r = SplitResp (Req 'GET' "/landscapes/$demoLid/versions/$demoVid/model/objects")
$ocount = ($r.body | ConvertFrom-Json).modelObjects.Count
Write-Output "objects count=$ocount (HTTP $($r.status))"

Section 'READ 5: List connections'
$r = SplitResp (Req 'GET' "/landscapes/$demoLid/versions/$demoVid/model/connections")
$ccount = ($r.body | ConvertFrom-Json).modelConnections.Count
Write-Output "connections count=$ccount (HTTP $($r.status))"

Section 'READ 6: List ADRs'
$r = SplitResp (Req 'GET' "/landscapes/$demoLid/versions/$demoVid/adrs")
$acount = ($r.body | ConvertFrom-Json).adrs.Count
Write-Output "adrs count=$acount (HTTP $($r.status))"

Section 'READ 7: Get single object by id (Demo App)'
$r = SplitResp (Req 'GET' "/landscapes/$demoLid/versions/$demoVid/model/objects/$demoAppId")
Show $r

Section 'READ 8: Object dependencies (JSON export)'
$r = SplitResp (Req 'GET' "/landscapes/$demoLid/versions/$demoVid/model/objects/$demoAppId/dependencies/export/json")
Show $r

Section 'READ 9: List diagrams'
$r = SplitResp (Req 'GET' "/landscapes/$demoLid/versions/$demoVid/diagrams")
Show $r

Section 'READ 10: List flows'
$r = SplitResp (Req 'GET' "/landscapes/$demoLid/versions/$demoVid/flows")
Show $r

Section 'READ 11: List versions'
$r = SplitResp (Req 'GET' "/landscapes/$demoLid/versions")
Show $r

Section 'READ 12: Action logs (audit history)'
$r = SplitResp (Req 'GET' "/landscapes/$demoLid/action-logs")
Show $r

# ============ WRITE DEMOS (throwaway, cleaned up) ============
Section 'WRITE 1: Create throwaway app under Demo System'
$tmp = NewTmp
WriteJson $tmp @{ name = 'Scratch Demo App'; type = 'app'; parentId = $demoSystemId; description = 'Throwaway app created by the IcePanel MCP-equivalent demo to prove create-object works.'; status = 'live' }
$r = SplitResp (Req 'POST' "/landscapes/$demoLid/versions/$demoVid/model/objects" $tmp)
Remove-Item $tmp -Force
Show $r
$newApp = $null
if ($r.status -match '200') { $newApp = ($r.body | ConvertFrom-Json).modelObject.id; Write-Output "newAppId=$newApp" }

Section 'WRITE 2: Update the throwaway app (rename + add caption)'
if ($newApp) {
    $tmp = NewTmp
    WriteJson $tmp @{ name = 'Scratch Demo App (renamed)'; type = 'app'; parentId = $demoSystemId; caption = 'Renamed by update-object demo'; description = 'Updated description via PUT.' }
    $r = SplitResp (Req 'PUT' "/landscapes/$demoLid/versions/$demoVid/model/objects/$newApp" $tmp)
    Remove-Item $tmp -Force
    Show $r
}

Section 'WRITE 3: Create throwaway connection Operator -> new app'
$newConn = $null
if ($newApp) {
    $tmp = NewTmp
    WriteJson $tmp @{ name = 'evaluates'; direction = 'outgoing'; originId = $demoActorId; targetId = $newApp; status = 'live' }
    $r = SplitResp (Req 'POST' "/landscapes/$demoLid/versions/$demoVid/model/connections" $tmp)
    Remove-Item $tmp -Force
    Show $r
    if ($r.status -match '200') { $newConn = ($r.body | ConvertFrom-Json).modelConnection.id; Write-Output "newConnId=$newConn" }
}

Section 'WRITE 4: Delete the throwaway connection'
if ($newConn) {
    $r = SplitResp (Req 'DELETE' "/landscapes/$demoLid/versions/$demoVid/model/connections/$newConn")
    Show $r
}

Section 'WRITE 5: Delete the throwaway app'
if ($newApp) {
    $r = SplitResp (Req 'DELETE' "/landscapes/$demoLid/versions/$demoVid/model/objects/$newApp")
    Show $r
}

Section 'WRITE 6: Create throwaway ADR'
$tmp = NewTmp
WriteJson $tmp @{ name = 'ADR 0099 - Scratch Demo throwaway'; status = 'draft'; description = 'Throwaway ADR to prove create-ADR works.'; content = '# ADR 0099 - Scratch Demo throwaway`n`n## Status`nDraft`n`n## Context`nDemo.`n`n## Decision`nDelete after.' }
$r = SplitResp (Req 'POST' "/landscapes/$demoLid/versions/$demoVid/adrs" $tmp)
Remove-Item $tmp -Force
Show $r
$newAdr = $null
if ($r.status -match '200') { $newAdr = ($r.body | ConvertFrom-Json).adr.id; Write-Output "newAdrId=$newAdr" }

Section 'WRITE 7: Read back ADRs to confirm'
$r = SplitResp (Req 'GET' "/landscapes/$demoLid/versions/$demoVid/adrs")
Show $r

Section 'WRITE 8: Delete the throwaway ADR'
if ($newAdr) {
    $r = SplitResp (Req 'DELETE' "/landscapes/$demoLid/versions/$demoVid/adrs/$newAdr")
    Show $r
}

# ============ SEARCH DEMO (MCP natural-language query equivalent) ============
Section 'SEARCH 1: Natural-language query via search endpoint'
$tmp = NewTmp
WriteJson $tmp @{ query = 'What does the Demo App depend on?' }
$r = SplitResp (Req 'POST' "/landscapes/$demoLid/versions/$demoVid/search" $tmp)
Remove-Item $tmp -Force
Show $r

Write-Output "`n=== Demo complete ==="
