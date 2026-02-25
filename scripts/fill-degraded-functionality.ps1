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
    'NORM-028' = @{
        ThreatAlignment = 'Institutional control'
        FailureIfDowngraded = 'Essential workflows fail under constrained resources, forcing users to rely on institutional systems (cloud sync, third-party portals, connectivity) that expand surveillance and control surface.'
        WhyShouldInsufficient = 'Graceful degradation is a safety baseline in hostile conditions; optional support causes predictable service exclusion.'
        VerificationMethod = 'Execute constrained-resource test matrix (2G, low-memory, high-latency, reduced-input), confirm essential workflows remain usable, verify no hidden telemetry activation in degraded mode, and confirm no sync-required-to-continue prompts are emitted.'
        ReferenceImplStatus = 'Partial'
        EvidenceNotes = 'PainTracker meets core low-bandwidth/mobile behavior but has progressive enhancement and accessibility gaps under degraded contexts. To reach Met: ship full degraded-mode baseline including non-JS and accessibility-complete operation.'
    }
    'NORM-029' = @{
        ThreatAlignment = 'Network tampering'
        FailureIfDowngraded = 'Heavy initial payloads fail under weak links, preventing timely access to critical workflows.'
        WhyShouldInsufficient = 'Low-bandwidth users cannot choose better network conditions; baseline payload budget must be enforced, not aspirational.'
        VerificationMethod = 'Throttle to simulated 2G, measure initial HTML payload and first-interaction completion time, and verify budget conformance in CI performance checks.'
        ReferenceImplStatus = 'Met'
        EvidenceNotes = 'Reference mapping reports successful 2G core-path execution under simulated constrained network conditions.'
    }
    'NORM-030' = @{
        ThreatAlignment = 'Institutional control'
        FailureIfDowngraded = 'Users on older or constrained devices are excluded from core access during high-need periods.'
        WhyShouldInsufficient = 'Device-floor compatibility is an inclusion boundary; non-mandatory support creates structural denial of service for vulnerable users.'
        VerificationMethod = 'Run memory-constrained device tests and profile runtime memory footprint during core workflows; verify stability at specified RAM floor.'
        ReferenceImplStatus = 'Partial'
        EvidenceNotes = 'Reference mapping claims low-memory support but evidence cites iPhone 6s (1GB RAM), which does not conclusively prove operation below 512MB. To reach Met: publish reproducible test evidence on <512MB target hardware/emulation.'
    }
    'NORM-031' = @{
        ThreatAlignment = 'Institutional control'
        FailureIfDowngraded = 'Users who cannot use pointer/touch input are blocked from complete task execution.'
        WhyShouldInsufficient = 'Complete keyboard operability is binary for affected users; partial compliance leaves inaccessible critical controls.'
        VerificationMethod = 'Run end-to-end keyboard-only audits across all interactive elements, including date pickers/charts, with tab order and activation checks, and confirm no UI controls are mouse-only event handlers without keyboard equivalents.'
        ReferenceImplStatus = 'Not Met'
        EvidenceNotes = 'Reference mapping reports keyboard access for core forms but not complete coverage; date picker/chart interactions still require pointer input. To reach Met: implement full keyboard parity for all controls and validate with automated/manual accessibility tests.'
    }
    'NORM-032' = @{
        ThreatAlignment = 'Network tampering'
        FailureIfDowngraded = 'Resource shocks cause hard failures instead of reduced-mode continuity, interrupting critical user tasks.'
        WhyShouldInsufficient = 'Degradation behavior must be deterministic; optional fallback logic leads to brittle failures in exactly the conditions this principle targets.'
        VerificationMethod = 'Inject CPU, memory, and bandwidth constraints and verify non-critical features degrade first while essential create/read/update paths remain operational.'
        ReferenceImplStatus = 'Partial'
        EvidenceNotes = 'Reference mapping indicates partial progressive enhancement and JS dependency, so degradation behavior is not complete across all contexts. To reach Met: provide robust no-JS baseline and explicit feature-priority degradation policy.'
    }
    'NORM-033' = @{
        ThreatAlignment = 'Network tampering'
        FailureIfDowngraded = 'Automatic media fetch increases data exhaustion risk and covertly exposes users to bandwidth and tracking harms.'
        WhyShouldInsufficient = 'User-controlled media loading is a direct harm-prevention control for constrained or monitored connections.'
        VerificationMethod = 'Inspect network traces on first load and workflow navigation to confirm no media requests occur until explicit user action.'
        ReferenceImplStatus = 'Met'
        EvidenceNotes = 'Reference mapping states media/attachments are never auto-loaded and require explicit user request.'
    }
    'NORM-034' = @{
        ThreatAlignment = 'Institutional control'
        FailureIfDowngraded = 'Accessibility gaps systematically exclude users with assistive needs from essential functions.'
        WhyShouldInsufficient = 'WCAG AA is a minimum interoperability floor; partial accessibility leaves predictable functional denial for disabled users.'
        VerificationMethod = 'Run WCAG 2.1 AA audits (contrast, keyboard, semantics, ARIA, screen-reader flows), verify passing results on critical workflows, and confirm core workflow completion time stays within defined tolerance under screen-reader mode.'
        ReferenceImplStatus = 'Not Met'
        EvidenceNotes = 'Reference mapping explicitly reports WCAG AA gaps (chart contrast and incomplete screen-reader/date-picker support). To reach Met: remediate failing elements and publish passing WCAG audit results.'
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
