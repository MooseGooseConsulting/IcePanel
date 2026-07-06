# IcePanel REST probe — run via: doppler run -p dev-tools -c dev -- powershell -NoProfile -File .\tools\icepanel-rest-probe.ps1
# Reads ICE_PANEL_ADMIN from the injected environment; never prints the value.
$ErrorActionPreference = 'Stop'

if (-not $env:ICE_PANEL_ADMIN) { Write-Output 'ICE_PANEL_ADMIN=missing'; exit 2 }
Write-Output ("ICE_PANEL_ADMIN=set (length={0})" -f $env:ICE_PANEL_ADMIN.Length)

$base = 'https://api.icepanel.io/v1'
$hAccept = 'Accept: application/json'
$hAuth = "Authorization: ApiKey $($env:ICE_PANEL_ADMIN)"

function Call([string]$path) {
    $url = "$base$path"
    try {
        $resp = curl.exe -s -w "`nHTTP_STATUS:%{http_code}" $url -H $hAccept -H $hAuth
        Write-Output "=== GET $path ==="
        Write-Output $resp
        Write-Output ''
    } catch {
        Write-Output "=== GET $path === ERROR: $_"
    }
}

Call '/organizations'

# List landscapes for the discovered org
$org = '8kpJ4KngNPCU2sbVFkgV'
Call "/organizations/$org/landscapes"
