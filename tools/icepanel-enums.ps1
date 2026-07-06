# Fetch IcePanel enum schemas. Run via: doppler run -p dev-tools -c dev -- powershell -NoProfile -File .\tools\icepanel-enums.ps1
$ErrorActionPreference = 'Stop'
if (-not $env:ICE_PANEL_ADMIN) { Write-Output 'ICE_PANEL_ADMIN=missing'; exit 2 }
$hAuth = "Authorization: ApiKey $($env:ICE_PANEL_ADMIN)"
$hAccept = 'Accept: application/json'

$names = @('ImportModelObjectType','ModelConnectionDirection','ModelObjectStatus','ModelConnectionStatus','TagColor','TagGroupIcon','ImportIconNullable','ImportLink','ModelObjectType','ModelObjectIconNullable','ADR','Flow','Team','Technology')
foreach ($n in $names) {
    Write-Output "=== $n ==="
    $resp = curl.exe -s "https://api.icepanel.io/v1/schemas/$n" -H $hAccept -H $hAuth
    Write-Output $resp
    Write-Output ''
}
