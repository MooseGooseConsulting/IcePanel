# Fix archiver.json hierarchy: components must parent an app/store, not a system.
# Add two grouping apps under arch-system and reparent the 21 components.
$repoRoot = Split-Path $PSScriptRoot -Parent
$path = Join-Path $repoRoot 'imports\archive\models\archiver.json'
$j = Get-Content -Raw $path | ConvertFrom-Json

# Insert two grouping apps right after the CLI app (arch-cli).
$ingestApp = [PSCustomObject]@{
    id = 'arch-app-ingest'; name = 'Ingestion & Parsers'; type = 'app'
    parentId = 'arch-system'; status = 'live'; tagIds = @('arch-tag-live','arch-tag-ingest')
    external = $false; caption = 'discovery + per-tool parsers'
    description = 'Grouping app: the live discovery/contracts/taxonomy/registry components and the per-tool parsers. Components live here because IcePanel requires components to parent an app or store.'
}
$rawApp = [PSCustomObject]@{
    id = 'arch-app-raw'; name = 'Raw Layer & Projections'; type = 'app'
    parentId = 'arch-system'; status = 'future'; tagIds = @('arch-tag-future','arch-tag-storage')
    external = $false; caption = 'planned v2 raw + projection components'
    description = 'Grouping app: the 7 planned v2 components (raw records, projections, native-id, cursors, row-hash, reconciliation, subagent modeling).'
}

# Find index of arch-cli to insert after it.
$idx = -1
for ($i = 0; $i -lt $j.modelObjects.Count; $i++) { if ($j.modelObjects[$i].id -eq 'arch-cli') { $idx = $i; break } }
$insertAt = $idx + 1
$j.modelObjects = $j.modelObjects[0..($insertAt-1)] + @($ingestApp, $rawApp) + $j.modelObjects[$insertAt..($j.modelObjects.Count-1)]

# Reparent the 21 components.
$ingestKids = @('arch-discovery','arch-contracts','arch-stream-taxonomy','arch-tool-registry',
                'arch-parser-codex','arch-parser-claude-code','arch-parser-opencode','arch-parser-kilo',
                'arch-parser-kimi','arch-parser-qwen','arch-parser-gemini','arch-parser-copilot-cli','arch-parser-vscode-family')
$rawKids = @('arch-raw-records','arch-projections','arch-native-id','arch-cursors','arch-row-hash','arch-reconciliation','arch-subagent-model')

foreach ($o in $j.modelObjects) {
    if ($o.type -ne 'component') { continue }
    if ($ingestKids -contains $o.id) { $o.parentId = 'arch-app-ingest' }
    elseif ($rawKids -contains $o.id) { $o.parentId = 'arch-app-raw' }
}

# Save (ASCII, depth 12).
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($path, ($j | ConvertTo-Json -Depth 12), $utf8NoBom)

# Verify: every component now has an app/store parent.
$bad = @()
$ids = $j.modelObjects | ForEach-Object { $_.id }
foreach ($o in $j.modelObjects) {
    if ($o.type -eq 'component') {
        $parent = $j.modelObjects | Where-Object { $_.id -eq $o.parentId }
        if (-not $parent -or ($parent.type -ne 'app' -and $parent.type -ne 'store')) {
            $bad += "$($o.id) -> parent $($o.parentId) ($($parent.type))"
        }
    }
}
$objCount = $j.modelObjects.Count
$compCount = ($j.modelObjects | Where-Object { $_.type -eq 'component' }).Count
$appCount = ($j.modelObjects | Where-Object { $_.type -eq 'app' }).Count
Write-Output "objects=$objCount apps=$appCount components=$compCount badParents=$($bad.Count)"
if ($bad.Count) { $bad | ForEach-Object { Write-Output "  BAD: $_" } } else { Write-Output 'All components have valid app/store parents.' }

# Non-ASCII check on the written file.
$raw = Get-Content -Raw $path
$nonAscii = ([regex]::Matches($raw, '[^\x00-\x7F]')).Count
Write-Output "nonAscii=$nonAscii"
