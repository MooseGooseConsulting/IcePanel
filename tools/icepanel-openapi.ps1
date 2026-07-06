# Fetch IcePanel OpenAPI spec + remaining schemas. Run via: doppler run -p dev-tools -c dev -- powershell -NoProfile -File .\tools\icepanel-openapi.ps1
$ErrorActionPreference = 'SilentlyContinue'
if (-not $env:ICE_PANEL_ADMIN) { Write-Output 'ICE_PANEL_ADMIN=missing'; exit 2 }
$hAuth = "Authorization: ApiKey $($env:ICE_PANEL_ADMIN)"
$hAccept = 'Accept: application/json'

Write-Output '=== OpenAPI JSON (api.icepanel.io/openapi.json) ==='
$r = curl.exe -s -w "`nHTTP_STATUS:%{http_code}" 'https://api.icepanel.io/openapi.json' -H $hAccept -H $hAuth
Write-Output $r
Write-Output ''

Write-Output '=== OpenAPI JSON (developer.icepanel.io/openapi.json) ==='
$r = curl.exe -s -w "`nHTTP_STATUS:%{http_code}" 'https://developer.icepanel.io/openapi.json' -H $hAccept
Write-Output $r
Write-Output ''

$names = @('ADRStatus','ADRStatusChange','ADRRelatedItem','FlowStep','ImportIcon','ModelObjectIcon','ModelObjectDiagram','CreateLandscape','CreateModelObject','CreateADR','CreateFlow')
foreach ($n in $names) {
    Write-Output "=== schema $n ==="
    $resp = curl.exe -s "https://api.icepanel.io/v1/schemas/$n" -H $hAccept -H $hAuth
    Write-Output $resp
    Write-Output ''
}
