# Count objects/connections/adrs from a driver 'list' output file.
param([string]$File)
$raw = Get-Content -Raw $File
# Split on the === markers and parse each JSON chunk.
$sections = $raw -split '=== [A-Z ]+ ==='
$objCount = 0; $connCount = 0; $adrCount = 0; $domCount = 0; $tagCount = 0
foreach ($s in $sections) {
    $s = ($s -replace 'HTTP_STATUS:\d+', '').Trim()
    if (-not $s) { continue }
    try {
        $j = $s | ConvertFrom-Json
        if ($j.modelObjects) { $objCount = $j.modelObjects.Count }
        if ($j.modelConnections) { $connCount = $j.modelConnections.Count }
        if ($j.adrs) { $adrCount = $j.adrs.Count }
        if ($j.domains) { $domCount = $j.domains.Count }
        if ($j.tags) { $tagCount = $j.tags.Count }
    } catch {}
}
Write-Output "domains=$domCount objects=$objCount connections=$connCount adrs=$adrCount tags=$tagCount"
