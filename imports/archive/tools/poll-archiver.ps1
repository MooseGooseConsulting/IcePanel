# Poll an import to terminal status and print full body. Also dump action-logs.
$ErrorActionPreference = 'SilentlyContinue'
if (-not $env:ICE_PANEL_ADMIN) { Write-Output 'ICE_PANEL_ADMIN=missing'; exit 2 }
$base = 'https://api.icepanel.io/v1'
$hAuth = "Authorization: ApiKey $($env:ICE_PANEL_ADMIN)"
$hAccept = 'Accept: application/json'
$lid = 'Q6smKpwNRmY1GsLzvqni'
$vid = 'CDrnlqJoHCGjscZCeoRN'
$iid = 'kIR1964w3Ka9rXIH3dmJ'

for ($i = 0; $i -lt 30; $i++) {
    Start-Sleep -Seconds 3
    $st = curl.exe -s "$base/landscapes/$lid/versions/$vid/import/$iid" -H $hAccept -H $hAuth
    $m = [regex]::Match($st, '"status":"([^"]+)"')
    $s = if ($m.Success) { $m.Groups[1].Value } else { '?' }
    Write-Output "poll $i status=$s"
    if ($s -eq 'completed' -or $s -eq 'error' -or $s -eq 'failed') {
        Write-Output "FULL: $st"
        break
    }
}

Write-Output "`n=== action-logs ==="
$logs = curl.exe -s "$base/landscapes/$lid/action-logs" -H $hAccept -H $hAuth
Write-Output $logs

Write-Output "`n=== verify objects ==="
$objs = curl.exe -s "$base/landscapes/$lid/versions/$vid/model/objects" -H $hAccept -H $hAuth
$oCount = (($objs | ConvertFrom-Json).modelObjects.Count)
Write-Output "objects=$oCount"
