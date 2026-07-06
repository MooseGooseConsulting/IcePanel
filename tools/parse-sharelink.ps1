# Extract share-link + share-link update schemas from the OpenAPI spec.
$repoRoot = Split-Path $PSScriptRoot -Parent
$lines = Get-Content -LiteralPath (Join-Path $repoRoot 'tools\openapi-output.txt')
$spec = $lines[5] | ConvertFrom-Json

function ResolveRef($ref, $root) { if (-not $ref) { return $null }; $parts = $ref.TrimStart('#/').Split('/'); $node = $root; foreach ($p in $parts) { $node = $node.$p }; return $node }

$path = '/landscapes/{landscapeId}/versions/{versionId}/share-link'
$op = $spec.paths.$path
Write-Output "share-link methods: $($op.PSObject.Properties.Name -join ', ')"
foreach ($m in $op.PSObject.Properties.Name) {
    $o = $op.$m
    Write-Output "[$m] operationId=$($o.operationId)"
    if ($o.parameters) { foreach ($p in $o.parameters) { Write-Output "  param: $($p.name) in=$($p.in) required=$($p.required)" } }
    $rb = $o.requestBody
    if ($rb) {
        $ref = $rb.content.'application/json'.schema.'$ref'
        Write-Output "  requestBody ref: $ref"
        $schema = ResolveRef $ref $spec
        if ($schema) { Write-Output ("  schema: " + ($schema | ConvertTo-Json -Depth 6 -Compress)) }
    }
}
