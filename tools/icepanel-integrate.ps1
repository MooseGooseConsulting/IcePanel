# Agent 6: cross-landscape integration.
# 1) Create share links for all 6 landscapes (clickable URLs for the user).
# 2) Update the Portfolio landscape's system objects with links to the detail landscapes.
# 3) Run a cross-landscape "Doppler" dependency query (search each landscape).
$ErrorActionPreference = 'SilentlyContinue'
if (-not $env:ICE_PANEL_ADMIN) { Write-Output 'ICE_PANEL_ADMIN=missing'; exit 2 }
$repoRoot = Split-Path $PSScriptRoot -Parent
$shareLinksPath = Join-Path $repoRoot 'imports\share-links.json'
$base = 'https://api.icepanel.io/v1'
$hAuth = "Authorization: ApiKey $($env:ICE_PANEL_ADMIN)"
$hAccept = 'Accept: application/json'
$hJson = 'Content-Type: application/json'

function NewTmp() { $p = Join-Path $env:TEMP ("ice-" + [guid]::NewGuid().ToString('N') + ".json"); New-Item -ItemType File -Path $p -Force | Out-Null; return $p }
function WriteJson($path, $obj) { $obj | ConvertTo-Json -Compress -Depth 8 | Set-Content -LiteralPath $path -Encoding utf8 }
function Req([string]$method, [string]$path, [string]$bodyFile) {
    $url = "$base$path"
    if ($method -eq 'GET') { return curl.exe -s -w "`nHTTP_STATUS:%{http_code}" $url -H $hAccept -H $hAuth }
    $cargs = @('-s','-w',"`nHTTP_STATUS:%{http_code}",'-X',$method,$url,'-H',$hAccept,'-H',$hAuth,'-H',$hJson)
    if ($bodyFile) { $cargs += '--data-binary',"@$bodyFile" }
    return & curl.exe @cargs
}
function SplitResp($resp) { $lines = $resp -split "`n"; return @{ body = (($lines[0..($lines.Length-2)] -join "`n") -replace 'HTTP_STATUS:\d+',''); status = $lines[-1] } }
function LatestVersion([string]$lid) {
    $r = SplitResp (Req 'GET' "/landscapes/$lid/versions")
    $obj = $r.body | ConvertFrom-Json
    $latest = $obj.versions | Where-Object { $_.tags -contains 'latest' } | Select-Object -First 1
    if (-not $latest) { $latest = $obj.versions[0] }
    return $latest.id
}

$landscapes = @{
    'portfolio'  = @{ id = 'Efdez5uW6BfQjErrQ4Gx'; name = 'Patrick Portfolio' }
    'k8s'        = @{ id = 'JyXDiYoXVfa7Xz3AnEfY'; name = 'Coldaine K8s Platform' }
    'governance' = @{ id = 'Svbe4JxL01yfpIidvbHC'; name = 'Agent Governance' }
    'coldsearch' = @{ id = 'DbkFHxfNxrKks6oOISUw'; name = 'ColdSearch Runtime' }
    'archiver'   = @{ id = 'Q6smKpwNRmY1GsLzvqni'; name = 'LLM Archiver' }
    'demo'       = @{ id = 'qkdcU3yoajAeWB2ruOh2'; name = 'Scratch Demo' }
}

Write-Output '========== SHARE LINKS =========='
$shareLinks = @{}
foreach ($slug in $landscapes.Keys) {
    $lid = $landscapes[$slug].id
    $vid = LatestVersion $lid
    # Try GET first (links likely already exist); fall back to POST create.
    $r = SplitResp (Req 'GET' "/landscapes/$lid/versions/$vid/share-link")
    if ($r.status -notmatch '200') {
        $tmp = NewTmp
        WriteJson $tmp @{ protected = $false }
        $r = SplitResp (Req 'POST' "/landscapes/$lid/versions/$vid/share-link" $tmp)
        Remove-Item $tmp -Force
    }
    $obj = $null
    try { $obj = $r.body | ConvertFrom-Json } catch {}
    $url = $null
    if ($obj) {
        $url = $obj.url
        if (-not $url) { $url = $obj.defaultUrl }
        if (-not $url -and $obj.shareLink) { $url = $obj.shareLink.url }
    }
    $shareLinks[$slug] = $url
    Write-Output "$slug : $url (HTTP $($r.status))"
}

Write-Output "`n========== CROSS-LANDSCAPE DOPPLER QUERY =========="
foreach ($slug in $landscapes.Keys) {
    if ($slug -eq 'demo') { continue }
    $lid = $landscapes[$slug].id
    $vid = LatestVersion $lid
    $r = SplitResp (Req 'GET' "/landscapes/$lid/versions/$vid/search?search=Doppler&maxResults=5")
    $count = 0
    try { $count = ($r.body | ConvertFrom-Json).results.Count } catch {}
    Write-Output "$slug : Doppler search results=$count (HTTP $($r.status))"
}

Write-Output "`n========== LINK PORTFOLIO SYSTEMS TO DETAIL LANDSCAPES =========="
# Fetch Portfolio objects, find the systems that map to detail landscapes, update with links.
$portLid = $landscapes['portfolio'].id
$portVid = LatestVersion $portLid
$robj = SplitResp (Req 'GET' "/landscapes/$portLid/versions/$portVid/model/objects")
$objects = $robj.body | ConvertFrom-Json

# Map Portfolio system name substrings to detail landscape slugs.
$nameMap = @{
    'Homelab'              = 'k8s'
    'Agent Governance'     = 'governance'
    'ColdSearch'           = 'coldsearch'
    'LLM Conversation'     = 'archiver'
    'Learning Corpus'      = 'archiver'
}

$updated = 0
foreach ($o in $objects.modelObjects) {
    if ($o.type -ne 'system') { continue }
    $matchedSlug = $null
    foreach ($key in $nameMap.Keys) {
        if ($o.name -match $key) { $matchedSlug = $nameMap[$key]; break }
    }
    if (-not $matchedSlug) { continue }
    $detailUrl = $shareLinks[$matchedSlug]
    if (-not $detailUrl) { Write-Output "  no share link for $matchedSlug; skipping $($o.name)"; continue }

    # Build update body preserving required fields, append description + add link.
    $desc = $o.description
    if (-not $desc) { $desc = '' }
    $newDesc = $desc + " | Detailed C4 model: " + $landscapes[$matchedSlug].name + " landscape (" + $matchedSlug + ")."
    $linksObj = @{}
    try { $linksObj = $o.links } catch {}
    if (-not $linksObj) { $linksObj = @{} }
    # Add a link entry (RealityLink accepts a url field)
    $linkId = "detail-" + $matchedSlug
    $linksObj | Add-Member -NotePropertyName $linkId -NotePropertyValue @{ url = $detailUrl; name = $landscapes[$matchedSlug].name } -Force

    $body = @{
        name = $o.name
        type = $o.type
        parentId = $o.parentId
        description = $newDesc
        links = $linksObj
    }
    $tmp = NewTmp
    WriteJson $tmp $body
    $r = SplitResp (Req 'PUT' "/landscapes/$portLid/versions/$portVid/model/objects/$($o.id)" $tmp)
    Remove-Item $tmp -Force
    if ($r.status -match '200') { $updated++; Write-Output "  linked [$($o.name)] -> $matchedSlug ($detailUrl)" }
    else { Write-Output "  FAILED [$($o.name)] HTTP $($r.status) $($r.body)" }
}
Write-Output "Updated $updated portfolio systems with detail-landscape links."

# Save share links to a file for the final report.
$shareLinks | ConvertTo-Json | Set-Content -LiteralPath $shareLinksPath -Encoding utf8
Write-Output "`nShare links saved to $shareLinksPath"
