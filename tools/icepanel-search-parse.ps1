# Extract the search endpoint details from the OpenAPI spec.
$repoRoot = Split-Path $PSScriptRoot -Parent
$lines = Get-Content -LiteralPath (Join-Path $repoRoot 'tools\openapi-output.txt')
$spec = $lines[5] | ConvertFrom-Json
$search = $spec.paths.'/landscapes/{landscapeId}/versions/{versionId}/search'
if ($search) {
    Write-Output "search endpoint methods:"
    $search.PSObject.Properties.Name | ForEach-Object {
        $m = $_
        $op = $search.$m
        Write-Output "  [$m] operationId=$($op.operationId) summary=$($op.summary)"
        if ($op.parameters) {
            foreach ($p in $op.parameters) {
                Write-Output "    param: name=$($p.name) in=$($p.in) required=$($p.required)"
            }
        }
        $rb = $op.requestBody
        if ($rb) { Write-Output "    has requestBody: $($rb.content.'application/json'.schema.'$ref')" }
    }
} else {
    Write-Output 'search path not found'
}
