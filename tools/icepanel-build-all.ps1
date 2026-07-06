# IcePanel batch builder — creates all 5 modeling landscapes, imports models, creates ADRs.
# Run via: doppler run -p dev-tools -c dev -- powershell -NoProfile -File .\tools\icepanel-build-all.ps1
# Expects satellite import JSON under imports/archive/models/ (legacy bootstrap).
$ErrorActionPreference = 'Stop'
if (-not $env:ICE_PANEL_ADMIN) { Write-Output 'ICE_PANEL_ADMIN=missing'; exit 2 }

$repoRoot = Split-Path $PSScriptRoot -Parent
$importsDir = Join-Path $repoRoot 'imports\archive\models'

$base = 'https://api.icepanel.io/v1'
$org = '8kpJ4KngNPCU2sbVFkgV'
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
function SplitResp($resp) { $lines = $resp -split "`n"; return @{ body = ($lines[0..($lines.Length-2)] -join "`n"); status = $lines[-1] } }
function LatestVersion([string]$lid) {
    $r = SplitResp (Req 'GET' "/landscapes/$lid/versions")
    $obj = $r.body | ConvertFrom-Json
    $latest = $obj.versions | Where-Object { $_.tags -contains 'latest' } | Select-Object -First 1
    if (-not $latest) { $latest = $obj.versions[0] }
    return $latest.id
}
function WaitForImport([string]$lid, [string]$vid, [string]$importId) {
    for ($i = 0; $i -lt 30; $i++) {
        Start-Sleep -Seconds 2
        $st = SplitResp (Req 'GET' "/landscapes/$lid/versions/$vid/import/$importId")
        $m = [regex]::Match($st.body, '"status":"([^"]+)"')
        $s = if ($m.Success) { $m.Groups[1].Value } else { 'unknown' }
        Write-Output "    poll $i status=$s"
        if ($s -eq 'completed' -or $s -eq 'failed' -or $s -eq 'imported' -or $s -eq 'done') { return $s }
    }
    return 'timeout'
}

$landscapes = @(
    @{ name = 'Patrick Portfolio';        slug = 'portfolio'   },
    @{ name = 'Coldaine K8s Platform';    slug = 'k8s'         },
    @{ name = 'Agent Governance';         slug = 'governance'  },
    @{ name = 'ColdSearch Runtime';       slug = 'coldsearch'  },
    @{ name = 'LLM Archiver';             slug = 'archiver'    }
)

$map = @{}
foreach ($l in $landscapes) {
    $name = $l.name; $slug = $l.slug
    $importFile = Join-Path $importsDir "$slug.json"
    $adrsFile = Join-Path $importsDir "$slug-adrs.json"
    Write-Output "`n========== $name ($slug) =========="

    if (-not (Test-Path $importFile)) { Write-Output "  SKIP: $importFile not found"; continue }

    # 1. Create landscape
    $tmp = NewTmp; WriteJson $tmp @{ name = $name }
    $resp = SplitResp (Req 'POST' "/organizations/$org/landscapes" $tmp)
    Remove-Item $tmp -Force
    if ($resp.status -notmatch '200') { Write-Output "  create-landscape FAILED: $($resp.status) $($resp.body)"; continue }
    $lobj = $resp.body | ConvertFrom-Json
    $lid = $lobj.landscape.id
    $vid = $lobj.version.id
    Write-Output "  created landscapeId=$lid versionId=$vid"
    $map[$slug] = @{ landscapeId = $lid; versionId = $vid; name = $name }

    # 2. Import model
    $resp = SplitResp (Req 'POST' "/landscapes/$lid/versions/$vid/import" $importFile)
    Write-Output "  import submit: $($resp.status)"
    if ($resp.status -match '200') {
        $iobj = $resp.body | ConvertFrom-Json
        $importId = $iobj.landscapeImport.id
        if ($importId) {
            $final = WaitForImport $lid $vid $importId
            Write-Output "  import final=$final"
        }
    } else { Write-Output "  import error body: $($resp.body)" }

    # 3. ADRs
    if (Test-Path $adrsFile) {
        $adrs = Get-Content -Raw -LiteralPath $adrsFile | ConvertFrom-Json
        $count = 0
        foreach ($a in $adrs) {
            $tmp = NewTmp; WriteJson $tmp $a
            $ar = SplitResp (Req 'POST' "/landscapes/$lid/versions/$vid/adrs" $tmp)
            Remove-Item $tmp -Force
            if ($ar.status -match '200') { $count++ } else { Write-Output "  ADR failed: $($ar.status) $($ar.body)" }
        }
        Write-Output "  created $count ADRs"
    }

    # 4. Quick verify
    $objs = SplitResp (Req 'GET' "/landscapes/$lid/versions/$vid/model/objects")
    $oCount = ($objs.body | ConvertFrom-Json).modelObjects.Count
    $conns = SplitResp (Req 'GET' "/landscapes/$lid/versions/$vid/model/connections")
    $cCount = ($conns.body | ConvertFrom-Json).modelConnections.Count
    Write-Output "  verify: $oCount objects, $cCount connections"
}

$mapFile = Join-Path $importsDir 'landscapes-map.json'
$map | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $mapFile -Encoding utf8
Write-Output "`n========== LANDSCAPE MAP =========="
Get-Content -Raw $mapFile
Write-Output "`nDone."
