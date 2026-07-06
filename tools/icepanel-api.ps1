# IcePanel REST client — run via: doppler run -p dev-tools -c dev -- powershell -NoProfile -File .\tools\icepanel-api.ps1 <action> [args...]
# Actions: get <path> | post <path> <bodyFile> | put <path> <bodyFile> | delete <path> | raw <url>
# Reads ICE_PANEL_ADMIN from injected env; never prints the value.
$ErrorActionPreference = 'Stop'
if (-not $env:ICE_PANEL_ADMIN) { Write-Output 'ICE_PANEL_ADMIN=missing'; exit 2 }

$base = 'https://api.icepanel.io/v1'
$hAccept = 'Accept: application/json'
$hAuth = "Authorization: ApiKey $($env:ICE_PANEL_ADMIN)"
$hJson = 'Content-Type: application/json'

$action = $args[0]
if (-not $action) { Write-Output 'usage: icepanel-api.ps1 <get|post|put|delete|raw> <path> [bodyFile]'; exit 2 }

function Show($resp) { Write-Output $resp }

switch ($action) {
    'get' {
        $path = $args[1]
        $resp = curl.exe -s -w "`nHTTP_STATUS:%{http_code}" "$base$path" -H $hAccept -H $hAuth
        Show $resp
    }
    'raw' {
        $url = $args[1]
        $resp = curl.exe -s -w "`nHTTP_STATUS:%{http_code}" "$url" -H $hAccept -H $hAuth
        Show $resp
    }
    'post' {
        $path = $args[1]; $bodyFile = $args[2]
        $body = Get-Content -Raw -LiteralPath $bodyFile
        $resp = curl.exe -s -w "`nHTTP_STATUS:%{http_code}" -X POST "$base$path" -H $hAccept -H $hAuth -H $hJson --data-binary "@$bodyFile"
        Show $resp
    }
    'put' {
        $path = $args[1]; $bodyFile = $args[2]
        $resp = curl.exe -s -w "`nHTTP_STATUS:%{http_code}" -X PUT "$base$path" -H $hAccept -H $hAuth -H $hJson --data-binary "@$bodyFile"
        Show $resp
    }
    'delete' {
        $path = $args[1]
        $resp = curl.exe -s -w "`nHTTP_STATUS:%{http_code}" -X DELETE "$base$path" -H $hAccept -H $hAuth
        Show $resp
    }
    default { Write-Output "unknown action: $action"; exit 2 }
}
