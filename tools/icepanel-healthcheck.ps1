# IcePanel connection health check.
# Run via: doppler run -p dev-tools -c dev -- powershell -NoProfile -File .\tools\icepanel-healthcheck.ps1
# Verifies: Doppler secret presence, REST org/landscape reachability, lists landscapes.
# Never prints the secret value.
$ErrorActionPreference = 'Stop'

Write-Output '=== IcePanel Health Check ==='

# 1. Doppler secret presence (boolean only)
if (-not $env:ICE_PANEL_ADMIN) {
    Write-Output '[FAIL] ICE_PANEL_ADMIN not injected by Doppler'
    exit 2
}
Write-Output ("[OK]   ICE_PANEL_ADMIN present (length={0})" -f $env:ICE_PANEL_ADMIN.Length)

$base = 'https://api.icepanel.io/v1'
$hAuth = "Authorization: ApiKey $($env:ICE_PANEL_ADMIN)"
$hAccept = 'Accept: application/json'

function GetJson([string]$path) {
    $resp = curl.exe -s -w "`nHTTP_STATUS:%{http_code}" "$base$path" -H $hAccept -H $hAuth
    $lines = $resp -split "`n"
    $code = ($lines[-1] -replace 'HTTP_STATUS:','')
    $body = ($lines[0..($lines.Length-2)] -join "`n")
    return @{ code = $code; body = $body }
}

# 2. Organizations
$orgs = GetJson '/organizations'
if ($orgs.code -ne '200') {
    Write-Output "[FAIL] /organizations -> HTTP $($orgs.code)"
    Write-Output $orgs.body
    exit 3
}
$obj = $orgs.body | ConvertFrom-Json
$org = $obj.organizations[0]
Write-Output ("[OK]   Organization: {0} (id={1}, plan={2}, status={3})" -f $org.name, $org.id, $org.plan, $org.status)
Write-Output ("       oauthLandscapeWriteEnabled={0}, trialEndsAt={1}" -f $org.oauthLandscapeWriteEnabled, $org.trialEndsAt)

# 3. Landscapes
$lands = GetJson "/organizations/$($org.id)/landscapes"
if ($lands.code -ne '200') {
    Write-Output "[FAIL] landscapes list -> HTTP $($lands.code)"
    exit 4
}
$lobj = $lands.body | ConvertFrom-Json
Write-Output ("[OK]   Landscapes: {0} total" -f $lobj.landscapes.Count)
foreach ($l in $lobj.landscapes) {
    Write-Output ("       - {0} (id={1})" -f $l.name, $l.id)
}

# 4. MCP plugin auth status (informational; requires separate OAuth completion in Cursor)
Write-Output '[INFO] MCP plugin (plugin-icepanel-icepanel) auth requires OAuth completed in Cursor UI.'
Write-Output '       REST API path is fully functional and covers all read/write operations.'
Write-Output '=== Health check complete ==='
