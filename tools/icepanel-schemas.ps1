# Fetch IcePanel import sub-schemas. Run via: doppler run -p dev-tools -c dev -- powershell -NoProfile -File .\tools\icepanel-schemas.ps1
$ErrorActionPreference = 'Stop'
if (-not $env:ICE_PANEL_ADMIN) { Write-Output 'ICE_PANEL_ADMIN=missing'; exit 2 }
$hAuth = "Authorization: ApiKey $($env:ICE_PANEL_ADMIN)"
$hAccept = 'Accept: application/json'

$names = @('ModelObjectImport','ModelConnectionImport','TagImport','TagGroupImport','ModelObject','ModelConnection','Landscape','Version','Domain')
foreach ($n in $names) {
    Write-Output "=== $n ==="
    $resp = curl.exe -s "https://api.icepanel.io/v1/schemas/$n" -H $hAccept -H $hAuth
    Write-Output $resp
    Write-Output ''
}
