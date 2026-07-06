# IcePanel driver — orchestrates landscape creation, import, ADRs, listings.
# Run via: doppler run -p dev-tools -c dev -- powershell -NoProfile -File .\tools\icepanel-driver.ps1 <command> [args]
$ErrorActionPreference = 'Stop'
if (-not $env:ICE_PANEL_ADMIN) { Write-Output 'ICE_PANEL_ADMIN=missing'; exit 2 }

$base = 'https://api.icepanel.io/v1'
$org = '8kpJ4KngNPCU2sbVFkgV'
$hAuth = "Authorization: ApiKey $($env:ICE_PANEL_ADMIN)"
$hAccept = 'Accept: application/json'
$hJson = 'Content-Type: application/json'

function NewTmp() {
    $p = Join-Path $env:TEMP ("icepanel-" + [guid]::NewGuid().ToString('N') + ".json")
    New-Item -ItemType File -Path $p -Force | Out-Null
    return $p
}

function WriteJson($path, $obj) {
    $obj | ConvertTo-Json -Compress -Depth 8 | Set-Content -LiteralPath $path -Encoding utf8
}

function Req([string]$method, [string]$path, [string]$bodyFile) {
    $url = "$base$path"
    if ($method -eq 'GET') {
        $resp = curl.exe -s -w "`nHTTP_STATUS:%{http_code}" $url -H $hAccept -H $hAuth
    } else {
        $resp = curl.exe -s -w "`nHTTP_STATUS:%{http_code}" -X $method $url -H $hAccept -H $hAuth -H $hJson
        if ($bodyFile) { $resp = curl.exe -s -w "`nHTTP_STATUS:%{http_code}" -X $method $url -H $hAccept -H $hAuth -H $hJson --data-binary "@$bodyFile" }
    }
    return $resp
}

function SplitResp($resp) {
    $lines = $resp -split "`n"
    $status = $lines[-1]
    $body = ($lines[0..($lines.Length-2)] -join "`n")
    return @{ body = $body; status = $status }
}

function LatestVersion([string]$lid) {
    $resp = Req 'GET' "/landscapes/$lid/versions"
    $r = SplitResp $resp
    $obj = $r.body | ConvertFrom-Json
    $latest = $obj.versions | Where-Object { $_.tags -contains 'latest' } | Select-Object -First 1
    if (-not $latest) { $latest = $obj.versions[0] }
    return $latest.id
}

$cmd = $args[0]
if (-not $cmd) { Write-Output 'no command'; exit 2 }

switch ($cmd) {
    'create-landscape' {
        $name = $args[1]
        $tmp = NewTmp
        WriteJson $tmp @{ name = $name }
        $resp = Req 'POST' "/organizations/$org/landscapes" $tmp
        Remove-Item $tmp -Force
        Write-Output $resp
    }
    'get-version' {
        $lid = $args[1]
        $vid = LatestVersion $lid
        Write-Output "VERSION_ID=$vid"
    }
    'import' {
        $lid = $args[1]; $importPath = $args[2]
        $vid = LatestVersion $lid
        Write-Output "Using versionId=$vid"
        $resp = Req 'POST' "/landscapes/$lid/versions/$vid/import" $importPath
        Write-Output "IMPORT_SUBMIT:"
        Write-Output $resp
        $r = SplitResp $resp
        try {
            $obj = $r.body | ConvertFrom-Json
            $importId = $obj.landscapeImport.id
            if (-not $importId) { $importId = $obj.id }
            if ($importId) {
                Write-Output "Polling import $importId..."
                for ($i = 0; $i -lt 30; $i++) {
                    Start-Sleep -Seconds 2
                    $st = Req 'GET' "/landscapes/$lid/versions/$vid/import/$importId"
                    Write-Output "POLL $i : $st"
                    if ($st -match '"status":"(completed|failed|imported|done)"') { break }
                }
            }
        } catch {
            Write-Output "parse/poll error: $_"
        }
    }
    'adrs' {
        $lid = $args[1]; $adrsPath = $args[2]
        $vid = LatestVersion $lid
        Write-Output "Using versionId=$vid"
        $adrs = Get-Content -Raw -LiteralPath $adrsPath | ConvertFrom-Json
        foreach ($a in $adrs) {
            $tmp = NewTmp
            WriteJson $tmp $a
            $resp = Req 'POST' "/landscapes/$lid/versions/$vid/adrs" $tmp
            Remove-Item $tmp -Force
            Write-Output "ADR [$($a.name)] -> $resp"
        }
    }
    'list' {
        $lid = $args[1]
        $vid = LatestVersion $lid
        Write-Output "=== versionId=$vid ==="
        Write-Output "=== DOMAINS ==="
        Req 'GET' "/landscapes/$lid/versions/$vid/domains"
        Write-Output "`n=== OBJECTS ==="
        Req 'GET' "/landscapes/$lid/versions/$vid/model/objects"
        Write-Output "`n=== CONNECTIONS ==="
        Req 'GET' "/landscapes/$lid/versions/$vid/model/connections"
        Write-Output "`n=== ADRS ==="
        Req 'GET' "/landscapes/$lid/versions/$vid/adrs"
        Write-Output "`n=== TAGS ==="
        Req 'GET' "/landscapes/$lid/versions/$vid/tags"
        Write-Output "`n=== TAG GROUPS ==="
        Req 'GET' "/landscapes/$lid/versions/$vid/tag-groups"
    }
    'delete-landscape' {
        $lid = $args[1]
        $resp = Req 'DELETE' "/landscapes/$lid"
        Write-Output $resp
    }
    'delete-object' {
        $lid = $args[1]; $vid = $args[2]; $oid = $args[3]
        $resp = Req 'DELETE' "/landscapes/$lid/versions/$vid/model/objects/$oid"
        Write-Output $resp
    }
    'create-object' {
        $lid = $args[1]; $vid = $args[2]; $bodyFile = $args[3]
        $resp = Req 'POST' "/landscapes/$lid/versions/$vid/model/objects" $bodyFile
        Write-Output $resp
    }
    'update-object' {
        $lid = $args[1]; $vid = $args[2]; $oid = $args[3]; $bodyFile = $args[4]
        $resp = Req 'PUT' "/landscapes/$lid/versions/$vid/model/objects/$oid" $bodyFile
        Write-Output $resp
    }
    'create-connection' {
        $lid = $args[1]; $vid = $args[2]; $bodyFile = $args[3]
        $resp = Req 'POST' "/landscapes/$lid/versions/$vid/model/connections" $bodyFile
        Write-Output $resp
    }
    'delete-connection' {
        $lid = $args[1]; $vid = $args[2]; $cid = $args[3]
        $resp = Req 'DELETE' "/landscapes/$lid/versions/$vid/model/connections/$cid"
        Write-Output $resp
    }
    'create-diagram' {
        $lid = $args[1]; $vid = $args[2]; $bodyFile = $args[3]
        if (-not $bodyFile) {
            $modelId = $args[3]; $name = $args[4]; $type = $args[5]
            $tmp = NewTmp
            WriteJson $tmp @{ index = 0; modelId = $modelId; name = $name; type = $type }
            $resp = Req 'POST' "/landscapes/$lid/versions/$vid/diagrams" $tmp
            Remove-Item $tmp -Force
        } else {
            $resp = Req 'POST' "/landscapes/$lid/versions/$vid/diagrams" $bodyFile
        }
        Write-Output $resp
    }
    'list-diagrams' {
        $lid = $args[1]; $vid = if ($args[2]) { $args[2] } else { LatestVersion $lid }
        Req 'GET' "/landscapes/$lid/versions/$vid/diagrams"
    }
    'create-flow' {
        $lid = $args[1]; $vid = $args[2]; $bodyFile = $args[3]
        $resp = Req 'POST' "/landscapes/$lid/versions/$vid/flows" $bodyFile
        Write-Output $resp
    }
    'search' {
        $lid = $args[1]; $q = $args[2]
        $vid = LatestVersion $lid
        $tmp = NewTmp
        WriteJson $tmp @{ query = $q }
        $resp = Req 'POST' "/landscapes/$lid/versions/$vid/search" $tmp
        Remove-Item $tmp -Force
        Write-Output $resp
    }
    default { Write-Output "unknown command: $cmd"; exit 2 }
}
