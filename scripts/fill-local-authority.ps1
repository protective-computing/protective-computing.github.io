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
    'NORM-015' = @{
        ThreatAlignment = 'Institutional control'
        FailureIfDowngraded = 'Centralized dependency allows service operators or outages to block essential user workflows and deny access during crises.'
        WhyShouldInsufficient = 'Local control is a core safety property; advisory-only offline posture permits coercive lockout through platform or network control.'
        VerificationMethod = 'Environment: device in airplane mode with network inspection active (DevTools Network tab or proxy capture). Action: execute full CRUD cycle on a core record (create, read, update, delete), including app restart between operations. Observable result: zero outbound network requests, all changes persist across restart, and no sync-required/blocking prompts appear. Pass criteria: all essential workflows complete with zero network traffic and no blocking UI escalation. Fail criteria: any outbound request occurs, any operation blocks on connectivity, or dependency-escalation messaging appears.'
        ReferenceImplStatus = 'Partial'
        EvidenceNotes = 'PainTracker supports offline core workflows, but backup and some account-linked operations remain server-coupled. To reach Met: provide a fully documented no-server operating profile for all essential functions.'
    }
    'NORM-017' = @{
        ThreatAlignment = 'Institutional control'
        FailureIfDowngraded = 'Users lose ability to operate during censorship, outages, or deliberate account throttling at moments when records are most needed.'
        WhyShouldInsufficient = 'Essential workflow continuity must be guaranteed under degraded connectivity; optional compliance fails under predictable network denial conditions.'
        VerificationMethod = 'Disable network at OS level and execute full essential workflow test matrix; verify success criteria without deferred hard-blocks.'
        ReferenceImplStatus = 'Met'
        EvidenceNotes = 'Reference implementation claims full offline-first behavior for create/edit/delete core entries and validates operation in airplane mode.'
    }
    'NORM-018' = @{
        ThreatAlignment = 'Device seizure'
        FailureIfDowngraded = 'Without a complete local copy, users become dependent on remote availability and may lose critical access during account or network disruption.'
        WhyShouldInsufficient = 'Local possession of essential data is a resilience boundary; discretionary caching creates silent gaps at time-of-need.'
        VerificationMethod = 'Environment: app connected and synced, then network severed mid-session with forced reload in offline state. Action: create/modify records, interrupt sync mid-write, and reload the application while offline. Observable result: pre-existing records remain readable, partially synced edits remain locally visible, no silent rollback or data loss occurs, and no forced re-authentication is required. Pass criteria: local dataset remains fully accessible and internally consistent without server reachability. Fail criteria: records disappear, revert silently, or require reconnection to render.'
        ReferenceImplStatus = 'Met'
        EvidenceNotes = 'Reference implementation states full local journal copy persists on device and remains available without server contact.'
    }
    'NORM-019' = @{
        ThreatAlignment = 'Network tampering'
        FailureIfDowngraded = 'Blocking UX on sync creates denial-of-service by unstable or adversarial networks and prevents timely user actions.'
        WhyShouldInsufficient = 'Non-blocking sync is required to preserve agency under unreliable links; optional behavior reintroduces network-coupled lockout.'
        VerificationMethod = 'Environment: throttle connection to high latency (>=2000ms) and >=30% packet loss using DevTools or network proxy. Action: perform multiple write operations during instability, then close and reopen app before reconnection. Observable result: writes persist locally immediately, UI remains interactive (no blocking spinner longer than 3 seconds), queued writes sync after reconnection without duplication/corruption, and no hard error requires manual reset. Pass criteria: all edits survive instability and reconcile cleanly on reconnection. Fail criteria: write loss, duplication, UI lockup, or manual recovery required.'
        ReferenceImplStatus = 'Met'
        EvidenceNotes = 'Reference mapping describes asynchronous queue-based sync and conflict resolution without blocking core workflows.'
    }
    'NORM-020' = @{
        ThreatAlignment = 'Institutional control'
        FailureIfDowngraded = 'Forced online authentication for offline cache enables lockout by identity provider failure, censorship, or account coercion.'
        WhyShouldInsufficient = 'Offline access under disruption is a hard requirement; optional support permits predictable control chokepoints.'
        VerificationMethod = 'Expire server tokens, disable connectivity, and verify cached essential data remains accessible without network re-authentication.'
        ReferenceImplStatus = 'Met'
        EvidenceNotes = 'Reference implementation states offline access to cached data does not require live server authentication.'
    }
    'NORM-021' = @{
        ThreatAlignment = 'State surveillance'
        FailureIfDowngraded = 'Undocumented parity/sync behavior causes users to misjudge exposure and data consistency risks across offline/online transitions.'
        WhyShouldInsufficient = 'Transparency on parity and sync semantics is necessary for informed risk decisions; vague behavior increases accidental disclosure and data loss.'
        VerificationMethod = 'Environment: Device capable of toggling network (airplane mode). Network inspector enabled. Access to documented offline/online feature matrix and sync specification. Action: (1) Extract documented Offline/Online Feature Matrix from public docs. (2) Execute each essential workflow under fully offline state, intermittent connectivity (toggle mid-action), and fully online state. (3) Record feature availability, data visibility differences, sync trigger timing, and conflict resolution outcome (create/edit same record offline and online). (4) Capture storage snapshot before/after sync. (5) Compare observed behavior to documented sync triggers, conflict rules, and exposure differences. Pass Criteria: All documented offline features operate without server dependency. Observed sync triggers and conflict resolution behavior match documentation. No additional data exposure occurs when transitioning from offline to online beyond documented scope. Feature availability aligns with published matrix. Fail Criteria: Any offline-capable feature requires server reachability. Conflict resolution diverges from documented rules. Sync transmits undocumented data classes. Offline/online exposure differences are undocumented.'
        ReferenceImplStatus = 'Partial'
        EvidenceNotes = 'Core behavior is described in reference mapping, but a formal parity matrix and sync-state disclosure contract are not published. To reach Met: publish and version a parity/sync behavior specification.'
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
