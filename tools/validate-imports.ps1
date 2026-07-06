# Validate import JSON payloads parse and report counts + non-ASCII check.
$repoRoot = Split-Path $PSScriptRoot -Parent
$archive = Join-Path $repoRoot 'imports\archive\models'
$active = Join-Path $repoRoot 'imports'

$files = @{
    'portfolio-megamap' = @(
        (Join-Path $active 'portfolio-megamap-full.json')
    )
    'portfolio (archive)' = @(
        (Join-Path $archive 'portfolio.json'),
        (Join-Path $archive 'portfolio-adrs.json')
    )
    'k8s (archive)'       = @((Join-Path $archive 'k8s.json'), (Join-Path $archive 'k8s-adrs.json'))
    'governance (archive)' = @((Join-Path $archive 'governance.json'), (Join-Path $archive 'governance-adrs.json'))
    'coldsearch (archive)' = @((Join-Path $archive 'coldsearch.json'), (Join-Path $archive 'coldsearch-adrs.json'))
    'archiver (archive)'   = @((Join-Path $archive 'archiver.json'), (Join-Path $archive 'archiver-adrs.json'))
}

foreach ($slug in $files.Keys) {
    Write-Output "=== $slug ==="
    foreach ($f in $files[$slug]) {
        if (-not (Test-Path $f)) { Write-Output "  MISSING: $f"; continue }
        $raw = Get-Content -Raw $f
        $nonAscii = ($raw | Select-String -Pattern '[^\x00-\x7F]' -AllMatches).Matches.Count
        try {
            $j = $raw | ConvertFrom-Json
            $parts = @()
            if ($j.modelObjects) { $parts += ($j.modelObjects.Count.ToString() + ' objects') }
            if ($j.modelConnections) { $parts += ($j.modelConnections.Count.ToString() + ' connections') }
            if ($j.tagGroups) { $parts += ($j.tagGroups.Count.ToString() + ' tagGroups') }
            if ($j.tags) { $parts += ($j.tags.Count.ToString() + ' tags') }
            if ($j -is [array]) { $parts += ($j.Count.ToString() + ' adrs') }
            Write-Output ("  OK  " + (Split-Path $f -Leaf) + " : " + ($parts -join ', ') + " | nonAscii=$nonAscii")
        } catch {
            Write-Output ("  ERR " + (Split-Path $f -Leaf) + " : " + $_.Exception.Message + " | nonAscii=$nonAscii")
        }
    }
}
