param(
    [string]$CsvPath = ''
)

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$auditDir = Join-Path $PSScriptRoot 'audit-output'
$annexPath = Join-Path $root 'docs\spec\v1.0-must-justifications.html'

if ([string]::IsNullOrWhiteSpace($CsvPath)) {
    $latest = Get-ChildItem -Path $auditDir -Filter 'must-ledger-*.csv' |
        Where-Object { $_.Name -notlike 'must-ledger-deduped-*.csv' } |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    if ($null -eq $latest) {
        throw 'No source must-ledger CSV files found in scripts/audit-output.'
    }

    $CsvPath = $latest.FullName
}

if (-not (Test-Path -LiteralPath $CsvPath)) {
    throw "CSV not found: $CsvPath"
}

if (-not (Test-Path -LiteralPath $annexPath)) {
    throw "Annex file not found: $annexPath"
}

function Get-NormalizedText {
    param([string]$Text)

    if ($null -eq $Text) {
        return ''
    }

    return (($Text.ToLower() -replace '[^a-z0-9 ]', '') -replace '\s+', ' ').Trim()
}

function Get-IdNumber {
    param([string]$IdValue)

    $match = [regex]::Match($IdValue, '(\d+)')
    if ($match.Success) {
        return [int]$match.Groups[1].Value
    }

    return [int]::MaxValue
}

function Get-CompletenessScore {
    param($Row)

    $fields = @(
        'ThreatAlignment',
        'FailureIfDowngraded',
        'WhyShouldInsufficient',
        'VerificationMethod',
        'EvidenceNotes'
    )

    $score = 0
    foreach ($field in $fields) {
        $value = $Row.$field
        if (-not [string]::IsNullOrWhiteSpace($value) -and $value -ne '-') {
            $score++
        }
    }

    return $score
}

function Escape-Html {
    param([string]$Text)

    if ($null -eq $Text) {
        return ''
    }

    return [System.Net.WebUtility]::HtmlEncode($Text)
}

function Row-ValueOrDash {
    param([string]$Value)

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return '-'
    }

    return $Value
}

$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$dedupedPath = Join-Path $auditDir "must-ledger-deduped-$timestamp.csv"
$triagePath = Join-Path $auditDir "must-ledger-dupes-triage-$timestamp.txt"

$rows = Import-Csv -LiteralPath $CsvPath

$annotated = $rows | ForEach-Object {
    $normalized = Get-NormalizedText -Text $_.NormativeText
    $idNumber = Get-IdNumber -IdValue $_.ID
    $score = Get-CompletenessScore -Row $_

    [pscustomobject]@{
        Row = $_
        Normalized = $normalized
        IdNumber = $idNumber
        CompletenessScore = $score
    }
}

$groups = $annotated | Group-Object Normalized

$keptAnnotated = New-Object System.Collections.Generic.List[object]
$triageLines = New-Object System.Collections.Generic.List[string]

$groupIndex = 0
foreach ($group in $groups) {
    $groupIndex++
    $ordered = $group.Group | Sort-Object @{ Expression = 'CompletenessScore'; Descending = $true }, @{ Expression = 'IdNumber'; Ascending = $true }
    $keep = $ordered[0]
    $ids = ($ordered | ForEach-Object { $_.Row.ID })
    $idList = $ids -join ', '

    $keptAnnotated.Add($keep) | Out-Null

    if ($group.Count -gt 1) {
        $action = 'DELETE'
        $rationale = if ($keep.CompletenessScore -gt 0) {
            'Exact duplicate text group; kept the most semantically populated row and removed redundant duplicates.'
        }
        else {
            'Exact duplicate text group; kept lowest numeric ID as deterministic canonical row and removed redundant duplicates.'
        }

        $triageLines.Add("GroupIndex: $groupIndex") | Out-Null
        $triageLines.Add("IDs: $idList") | Out-Null
        $triageLines.Add("Action: $action") | Out-Null
        $triageLines.Add("CanonicalID: $($keep.Row.ID)") | Out-Null
        $triageLines.Add("Rationale: $rationale") | Out-Null
        $triageLines.Add('') | Out-Null
    }
}

$dedupedRows = $keptAnnotated |
    Sort-Object { $_.IdNumber } |
    ForEach-Object { $_.Row }

$dedupedRows | Export-Csv -LiteralPath $dedupedPath -NoTypeInformation -Encoding UTF8

if ($triageLines.Count -eq 0) {
    $triageLines.Add('No duplicate groups found.') | Out-Null
}

$triageLines | Set-Content -LiteralPath $triagePath -Encoding UTF8

$htmlRows = New-Object System.Collections.Generic.List[string]
foreach ($record in $dedupedRows) {
    $idText = Escape-Html -Text $record.ID
    $keywordText = Escape-Html -Text $record.Keyword
    $sectionText = Escape-Html -Text $record.Section
    $hrefText = Escape-Html -Text $record.SpecLocationHref
    $normativeText = Escape-Html -Text $record.NormativeText
    $threat = Escape-Html -Text (Row-ValueOrDash -Value $record.ThreatAlignment)
    $failure = Escape-Html -Text (Row-ValueOrDash -Value $record.FailureIfDowngraded)
    $why = Escape-Html -Text (Row-ValueOrDash -Value $record.WhyShouldInsufficient)
    $verification = Escape-Html -Text (Row-ValueOrDash -Value $record.VerificationMethod)
    $status = Escape-Html -Text (Row-ValueOrDash -Value $record.ReferenceImplStatus)
    $evidence = Escape-Html -Text (Row-ValueOrDash -Value $record.EvidenceNotes)
    $targetVersion = Escape-Html -Text (Row-ValueOrDash -Value $record.TargetVersion)

    $rowHtml = @"
      <tr>
        <td><code>$idText</code></td>
        <td><code>$keywordText</code></td>
        <td>$sectionText (<a href="$hrefText">link</a>)</td>
        <td>$normativeText</td>
        <td>$threat</td>
        <td>$failure</td>
        <td>$why</td>
        <td>$verification</td>
        <td>$status</td>
        <td>$evidence</td>
        <td>$targetVersion</td>
      </tr>
"@

    $htmlRows.Add($rowHtml.TrimEnd()) | Out-Null
}

$rowsContent = ($htmlRows -join "`r`n")
$annex = Get-Content -Raw -LiteralPath $annexPath -Encoding UTF8
$updatedAnnex = [regex]::Replace(
    $annex,
    '<tbody>[\s\S]*?</tbody>',
    "<tbody>`r`n$rowsContent`r`n    </tbody>",
    'IgnoreCase'
)
Set-Content -LiteralPath $annexPath -Value $updatedAnnex -Encoding UTF8

$duplicateGroupCount = @($groups | Where-Object { $_.Count -gt 1 }).Count

Write-Output "Source CSV: $CsvPath"
Write-Output "Deduped CSV: $dedupedPath"
Write-Output "Triage report: $triagePath"
Write-Output "Updated annex: $annexPath"
Write-Output "Source rows: $(@($rows).Count)"
Write-Output "Deduped rows: $(@($dedupedRows).Count)"
Write-Output "Duplicate groups: $duplicateGroupCount"
