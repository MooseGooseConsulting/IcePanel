# Prove landscapes landed: object/connection/ADR counts + sample object names per landscape.
$ErrorActionPreference = 'SilentlyContinue'
if (-not $env:ICE_PANEL_ADMIN) { exit 2 }
$base = 'https://api.icepanel.io/v1'
$hAuth = "Authorization: ApiKey $($env:ICE_PANEL_ADMIN)"
$hAccept = 'Accept: application/json'

function Req($path) {
    $resp = curl.exe -s "$base$path" -H $hAccept -H $hAuth
    return ($resp -replace 'HTTP_STATUS:\d+','')
}
function LatestVersion($lid) {
    $obj = (Req "/landscapes/$lid/versions") | ConvertFrom-Json
    $v = $obj.versions | Where-Object { $_.tags -contains 'latest' } | Select-Object -First 1
    if (-not $v) { $v = $obj.versions[0] }
    return $v.id
}

$lands = @{
    'Patrick Portfolio' = 'Efdez5uW6BfQjErrQ4Gx'
    'Coldaine K8s Platform' = 'JyXDiYoXVfa7Xz3AnEfY'
    'Agent Governance' = 'Svbe4JxL01yfpIidvbHC'
    'ColdSearch Runtime' = 'DbkFHxfNxrKks6oOISUw'
    'LLM Archiver' = 'Q6smKpwNRmY1GsLzvqni'
    'Scratch Demo' = 'qkdcU3yoajAeWB2ruOh2'
}

Write-Output 'LANDSCAPE PROOF (live IcePanel API)'
Write-Output '===================================='
foreach ($name in $lands.Keys) {
    $lid = $lands[$name]
    $vid = LatestVersion $lid
    $objs = (Req "/landscapes/$lid/versions/$vid/model/objects") | ConvertFrom-Json
    $conns = (Req "/landscapes/$lid/versions/$vid/model/connections") | ConvertFrom-Json
    $adrs = (Req "/landscapes/$lid/versions/$vid/adrs") | ConvertFrom-Json
    $named = $objs.modelObjects | Where-Object { $_.name -and $_.name.Trim() -ne '' } | Select-Object -First 5 -ExpandProperty name
    Write-Output ""
    Write-Output "$name"
    Write-Output "  landscapeId=$lid versionId=$vid"
    Write-Output "  objects=$($objs.modelObjects.Count) connections=$($conns.modelConnections.Count) adrs=$($adrs.adrs.Count)"
    Write-Output "  sample: $($named -join ' | ')"
}
