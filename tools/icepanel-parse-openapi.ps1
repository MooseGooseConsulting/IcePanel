# Parse IcePanel OpenAPI spec (line 6 of openapi-output.txt) and extract endpoint request bodies.
# Run via: powershell -NoProfile -File .\tools\icepanel-parse-openapi.ps1
$ErrorActionPreference = 'SilentlyContinue'
$repoRoot = Split-Path $PSScriptRoot -Parent
$lines = Get-Content -LiteralPath (Join-Path $repoRoot 'tools\openapi-output.txt')
$specLine = $lines[5]  # line 6 (0-indexed 5) is the api.icepanel.io/openapi.json body
$spec = $specLine | ConvertFrom-Json

Write-Output "=== PATHS ==="
$spec.paths.PSObject.Properties.Name | ForEach-Object { Write-Output $_ }
Write-Output ''

# Helper: resolve a $ref like #/components/schemas/Foo
function ResolveRef($ref, $root) {
    if (-not $ref) { return $null }
    $parts = $ref.TrimStart('#/').Split('/')
    $node = $root
    foreach ($p in $parts) { $node = $node.$p }
    return $node
}

function PrintOp($path, $method) {
    $op = $spec.paths.$path.$method
    if (-not $op) { return }
    $rb = $op.requestBody
    if (-not $rb) { Write-Output "[$method] $path  (no request body)"; return }
    $schemaRef = $rb.content.'application/json'.schema.'$ref'
    Write-Output "[$method] $path  operationId=$($op.operationId)"
    Write-Output "  requestBody ref: $schemaRef"
    $schema = ResolveRef $schemaRef $spec
    if ($schema) {
        $j = $schema | ConvertTo-Json -Depth 8 -Compress
        Write-Output "  schema: $j"
    }
}

$targets = @(
    '/organizations/{organizationId}/landscapes',
    '/landscapes/{landscapeId}/versions/{versionId}/import',
    '/landscapes/{landscapeId}/versions/{versionId}/diagrams',
    '/landscapes/{landscapeId}/versions/{versionId}/domains',
    '/landscapes/{landscapeId}/versions/{versionId}/tags',
    '/landscapes/{landscapeId}/versions/{versionId}/tag-groups',
    '/landscapes/{landscapeId}/versions/{versionId}/adrs',
    '/landscapes/{landscapeId}/versions/{versionId}/flows',
    '/landscapes/{landscapeId}/versions/{versionId}/model/objects',
    '/landscapes/{landscapeId}/versions/{versionId}/model/connections'
)
foreach ($t in $targets) {
    Write-Output "### $t"
    if ($spec.paths.$t) {
        PrintOp $t 'post'
        PrintOp $t 'put'
        PrintOp $t 'get'
        PrintOp $t 'delete'
    } else {
        Write-Output "  (not found in spec)"
    }
    Write-Output ''
}
