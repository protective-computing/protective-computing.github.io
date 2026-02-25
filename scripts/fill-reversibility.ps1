param(
    [string]$CsvPath = ''
)

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$auditDir = Join-Path $PSScriptRoot 'audit-output'
$annexPath = Join-Path $root 'docs\spec\v1.0-must-justifications.html'

if ([string]::IsNullOrWhiteSpace($CsvPath)) {
    $latest = Get-ChildItem -Path $auditDir -Filter 'must-ledger-deduped-*.csv' |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    if ($null -eq $latest) {
        throw 'No deduped must-ledger CSV files found in scripts/audit-output.'
    }

    $CsvPath = $latest.FullName
}

if (-not (Test-Path -LiteralPath $CsvPath)) {
    throw "CSV not found: $CsvPath"
}

if (-not (Test-Path -LiteralPath $annexPath)) {
    throw "Annex file not found: $annexPath"
}

function Escape-Html {
    param([string]$Text)
    if ($null -eq $Text) { return '' }
    return [System.Net.WebUtility]::HtmlEncode($Text)
}

function Value-OrDash {
    param([string]$Value)
    if ([string]::IsNullOrWhiteSpace($Value)) { return '-' }
    return $Value
}

$fills = @{
    'NORM-001' = @{
        ThreatAlignment = 'Institutional control'
        FailureIfDowngraded = 'Without bounded reversibility, accidental or coerced destructive actions become irreversible harm with no recovery path.'
        WhyShouldInsufficient = 'Reversibility is a safety invariant for vulnerable users; optional rollback guarantees fail under operational pressure.'
        VerificationMethod = 'Execute destructive-action suite and verify each action has documented recovery window, available undo path, and explicit irreversibility state after expiry.'
        ReferenceImplStatus = 'Met'
        EvidenceNotes = 'Reference implementation uses soft-delete and timed recovery windows for core entries, with documented expiry behavior.'
    }
    'NORM-003' = @{
        ThreatAlignment = 'Institutional control'
        FailureIfDowngraded = 'Users can lose critical records due to misclicks, stress, or interface confusion without practical restoration.'
        WhyShouldInsufficient = 'Undo for destructive operations cannot be advisory; absence creates immediate, irreversible consequence risk.'
        VerificationMethod = 'Test delete/modify/publish operations and confirm undo availability within the configured recovery window across online and offline states.'
        ReferenceImplStatus = 'Met'
        EvidenceNotes = 'Reference mapping includes undo recovery checkpoints for destructive operations and confirms restoration behavior during audits.'
    }
    'NORM-004' = @{
        ThreatAlignment = 'State surveillance'
        FailureIfDowngraded = 'Users cannot evaluate risk of delay-period actions and may unintentionally trigger irreversible transitions.'
        WhyShouldInsufficient = 'Recovery timing transparency is required for informed user control; hidden windows undermine protective decision-making.'
        VerificationMethod = 'Inspect UI surfaces for each destructive action to verify explicit recovery-window display and countdown consistency with backend policy.'
        ReferenceImplStatus = 'Met'
        EvidenceNotes = 'Reference mapping reports visible deletion grace period (for example, 30-day remaining indicator) before permanent purge.'
    }
    'NORM-005' = @{
        ThreatAlignment = 'Coercion / forced disclosure'
        FailureIfDowngraded = 'Immediate hard-delete enables coercers or accidental actions to erase evidence/history before user can recover or contest.'
        WhyShouldInsufficient = 'Mandatory confirmation plus delay is the only reliable guard against high-impact destructive abuse under stress or coercion.'
        VerificationMethod = 'Attempt destructive delete flows and verify explicit confirmation plus enforced minimum delay before irreversible purge is possible.'
        ReferenceImplStatus = 'Met'
        EvidenceNotes = 'Reference behavior uses confirmation plus delayed permanent deletion with recovery period, preventing instant irreversible data loss.'
    }
    'NORM-006' = @{
        ThreatAlignment = 'Institutional control'
        FailureIfDowngraded = 'Undocumented reversibility boundaries cause unsafe assumptions and prevent operators/reviewers from validating recovery guarantees.'
        WhyShouldInsufficient = 'Reversible/irreversible boundaries must be explicit and auditable; implicit behavior invites silent policy drift.'
        VerificationMethod = 'Environment: Latest release build. Access to state machine documentation (or equivalent state transition inventory), UI flows, API routes, and storage snapshot capability (IndexedDB/app data export). Action: (1) Generate a State Transition Inventory by enumerating all user-triggerable transitions (create, edit, delete, export, retention expiry, sync, reset, account change, device migration). (2) For each transition, classify as Reversible (explicit undo, restore, or rollback path exists) or Irreversible (no undo path). (3) For every Reversible transition: execute transition, execute documented recovery path, and capture before/after storage snapshot and UI state. (4) For every Irreversible transition: execute transition, attempt documented recovery path (if any), and confirm system communicates irreversibility clearly at time of action (UI capture required). (5) Compare observed reversibility behavior against documentation labels. Pass Criteria: Every documented state transition has an explicit reversibility classification. All Reversible transitions demonstrably restore prior state without residual data loss or hidden artifact persistence. All Irreversible transitions are clearly communicated before execution and behave irreversibly in practice. No transition behaves differently from its documented label. Fail Criteria: Any transition lacks classification. A labeled reversible action cannot be restored to its prior state. A labeled irreversible action can be partially undone without disclosure. Documentation and runtime behavior diverge.'
        ReferenceImplStatus = 'Partial'
        EvidenceNotes = 'Reference mapping demonstrates key reversible flows but does not publish a complete action-by-action reversibility matrix. To reach Met: publish a versioned reversibility boundary table for all destructive transitions.'
    }
}

$rows = Import-Csv -LiteralPath $CsvPath
$updatedCount = 0
foreach ($row in $rows) {
    if ($fills.ContainsKey($row.ID)) {
        $fill = $fills[$row.ID]
        $row.ThreatAlignment = $fill.ThreatAlignment
        $row.FailureIfDowngraded = $fill.FailureIfDowngraded
        $row.WhyShouldInsufficient = $fill.WhyShouldInsufficient
        $row.VerificationMethod = $fill.VerificationMethod
        $row.ReferenceImplStatus = $fill.ReferenceImplStatus
        $row.EvidenceNotes = $fill.EvidenceNotes
        $updatedCount++
    }
}

$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$outCsvPath = Join-Path $auditDir "must-ledger-deduped-$timestamp.csv"
$rows | Export-Csv -LiteralPath $outCsvPath -NoTypeInformation -Encoding UTF8

$htmlRows = New-Object System.Collections.Generic.List[string]
foreach ($record in $rows) {
    $idText = Escape-Html -Text $record.ID
    $keywordText = Escape-Html -Text $record.Keyword
    $sectionText = Escape-Html -Text $record.Section
    $hrefText = Escape-Html -Text $record.SpecLocationHref
    $normativeText = Escape-Html -Text $record.NormativeText
    $threat = Escape-Html -Text (Value-OrDash -Value $record.ThreatAlignment)
    $failure = Escape-Html -Text (Value-OrDash -Value $record.FailureIfDowngraded)
    $why = Escape-Html -Text (Value-OrDash -Value $record.WhyShouldInsufficient)
    $verification = Escape-Html -Text (Value-OrDash -Value $record.VerificationMethod)
    $status = Escape-Html -Text (Value-OrDash -Value $record.ReferenceImplStatus)
    $evidence = Escape-Html -Text (Value-OrDash -Value $record.EvidenceNotes)
    $targetVersion = Escape-Html -Text (Value-OrDash -Value $record.TargetVersion)

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

Write-Output "Source CSV: $CsvPath"
Write-Output "Output CSV: $outCsvPath"
Write-Output "Updated rows: $updatedCount"
Write-Output "Updated annex: $annexPath"
