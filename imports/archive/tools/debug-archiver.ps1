# Debug the archiver import failure — re-submit and show full import status body.
$ErrorActionPreference = 'SilentlyContinue'
if (-not $env:ICE_PANEL_ADMIN) { Write-Output 'ICE_PANEL_ADMIN=missing'; exit 2 }
$base = 'https://api.icepanel.io/v1'
$hAuth = "Authorization: ApiKey $($env:ICE_PANEL_ADMIN)"
$hAccept = 'Accept: application/json'
$hJson = 'Content-Type: application/json'
$lid = 'Q6smKpwNRmY1GsLzvqni'
$vid = 'CDrnlqJoHCGjscZCeoRN'
$importFile = 'D:\_projects\Scratch\imports\archiver.json'

Write-Output '=== submit import ==='
$resp = curl.exe -s -w "`nHTTP_STATUS:%{http_code}" -X POST "$base/landscapes/$lid/versions/$vid/import" -H $hAccept -H $hAuth -H $hJson --data-binary "@$importFile"
Write-Output $resp
$lines = $resp -split "`n"
$body = ($lines[0..($lines.Length-2)] -join "`n")
$obj = $body | ConvertFrom-Json
$importId = $obj.landscapeImport.id
Write-Output "importId=$importId"

if ($importId) {
    Start-Sleep -Seconds 3
    Write-Output '=== import status (full) ==='
    $st = curl.exe -s "$base/landscapes/$lid/versions/$vid/import/$importId" -H $hAccept -H $hAuth
    Write-Output $st
}

# Also check action-logs for the prior failed import
Write-Output "`n=== action-logs (last import errors) ==="
$logs = curl.exe -s "$base/landscapes/$lid/action-logs?maxResults=5" -H $hAccept -H $hAuth
Write-Output $logs
