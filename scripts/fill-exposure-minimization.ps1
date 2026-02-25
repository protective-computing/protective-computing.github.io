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

    if ($null -eq $Text) {
        return ''
    }

    return [System.Net.WebUtility]::HtmlEncode($Text)
}

function Value-OrDash {
    param([string]$Value)

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return '-'
    }

    return $Value
}

$fills = @{
    'NORM-007' = @{
        ThreatAlignment = 'State surveillance'
        FailureIfDowngraded = 'Unbounded collection or weak protection increases breach blast radius and exposes longitudinal health patterns.'
        WhyShouldInsufficient = 'Minimization, crypto, and retention controls are baseline harm-reduction controls; optional adoption leaves predictable exploitation paths open.'
        VerificationMethod = 'Environment: Clean install. Network inspector available. Access to app storage directory (or IndexedDB dump if web). Action: (1) Enumerate all persisted fields (schema + runtime writes) by exporting a storage snapshot after exercising every essential use-case workflow once. (2) For each persisted field, map it to the essential-use-case inventory ledger entry (field -> necessity). (3) Validate encryption by extracting storage artifacts and confirming no plaintext values for sensitive fields are present at rest (string search or structured decode). (4) Validate transport: if any network sync exists, capture outbound requests and confirm TLS-only transport and no sensitive fields appear in request bodies without encryption-at-application-layer where claimed. (5) Run retention test: set retention window to minimal value (test config), create records, wait past window, then snapshot storage and confirm records are absent or cryptographically unrecoverable within application access paths. Pass Criteria: Every persisted field has a necessity mapping; no plaintext sensitive values present at rest; no sensitive values transmitted in clear; records past retention window are not accessible and do not appear in storage snapshots. Fail Criteria: Any persisted field lacks necessity justification; any sensitive value appears in plaintext at rest or in transit; retention-expired records remain accessible or persist in storage.'
        ReferenceImplStatus = 'Partial'
        EvidenceNotes = 'PainTracker states essential-only collection, AES-256 at rest, TLS 1.3 in transit, and no sharing; local retention remains user-controlled and not fully automatic. To reach Met: enforce automatic local retention windows with documented override policy.'
    }
    'NORM-010' = @{
        ThreatAlignment = 'State surveillance'
        FailureIfDowngraded = 'Unjustified fields enable profiling, secondary inference, and coercive data requests beyond core care needs.'
        WhyShouldInsufficient = 'Without a mandatory per-field justification process, data scope drifts over time and reviewers cannot detect over-collection early.'
        VerificationMethod = 'Require a versioned field-justification ledger and verify each schema migration includes necessity, sensitivity class, and retention bound.'
        ReferenceImplStatus = 'Partial'
        EvidenceNotes = 'Reference implementation documents essential fields but does not publish a formal per-field minimization audit artifact. To reach Met: publish a versioned field-justification ledger tied to schema migrations.'
    }
    'NORM-011' = @{
        ThreatAlignment = 'Device seizure'
        FailureIfDowngraded = 'Lost or seized devices can reveal plaintext records, causing irreversible confidentiality loss.'
        WhyShouldInsufficient = 'At-rest encryption cannot be discretionary when threat model includes confiscation and endpoint compromise.'
        VerificationMethod = 'Attempt raw storage extraction from device backup, confirm absence of plaintext fragments via strings/grep scan, verify key-derivation method and parameters, and confirm keys are not persisted in plaintext config files or logs.'
        ReferenceImplStatus = 'Met'
        EvidenceNotes = 'PainTracker reports AES-256 GCM storage encryption and audit test confirms exported database is unreadable without decryption key.'
    }
    'NORM-012' = @{
        ThreatAlignment = 'Network tampering'
        FailureIfDowngraded = 'Transport interception permits content disclosure, manipulation, or downgrade attacks during sync/backup.'
        WhyShouldInsufficient = 'Weak transport guarantees collapse confidentiality in transit even if local storage is encrypted.'
        VerificationMethod = 'Environment: A controlled test session with network visibility. Use at least one TLS scanner (e.g., testssl.sh or sslyze) plus a packet capture tool (e.g., Wireshark/tshark). If the system has no network endpoints by design, verification is a negative test (no outbound). Action: (1) Identify every network endpoint used by the product (sync, updates, telemetry, third-party APIs) by running essential workflows while capturing traffic. (2) For each endpoint, run a TLS posture scan and record: supported protocol versions, ciphers, key exchange, certificate chain, HSTS (if web), and renegotiation behavior. (3) Attempt downgrade: force TLS 1.2 and weak cipher negotiation from the client side (scanner-supported). (4) Attempt plaintext: confirm no HTTP (non-TLS) endpoints are reachable for the same host/path patterns. (5) Inspect captured traffic payloads for sensitive field names/values (string search or structured decode) to ensure no application-layer plaintext is sent where encryption-at-application-layer is claimed. Pass Criteria: All observed endpoints require TLS; no HTTP reachable equivalents. TLS 1.0/1.1 not supported; TLS 1.2 allowed only if explicitly justified; TLS 1.3 preferred. Weak ciphers/legacy key exchange rejected. Downgrade attempts fail (handshake refused or negotiation prevented). No sensitive values appear in captured request/response bodies in clear where app-layer encryption is claimed. Fail Criteria: Any endpoint allows plaintext HTTP. TLS downgrade succeeds or weak suites negotiate. Any sensitive values observed in clear contrary to the spec disclosure/crypto claims.'
        ReferenceImplStatus = 'Met'
        EvidenceNotes = 'Reference mapping states TLS 1.3 for all communication and includes an OpenSSL verification checkpoint for cipher and downgrade posture.'
    }
    'NORM-013' = @{
        ThreatAlignment = 'Institutional control'
        FailureIfDowngraded = 'Undefined retention increases subpoena/disclosure exposure windows and amplifies harm from delayed compromise.'
        WhyShouldInsufficient = 'Retention limits must be enforceable defaults; guidance-only policies do not constrain operational drift.'
        VerificationMethod = 'Inspect per-field retention table, verify expiry removes logical references and blocks application-level access, confirm no documented restore path after expiry, and treat physical media destruction as out-of-scope unless explicitly guaranteed.'
        ReferenceImplStatus = 'Partial'
        EvidenceNotes = 'PainTracker specifies one-year auto-delete for server backups but keeps local entries indefinitely by user control, so not all fields have automatic minimal retention. To reach Met: define and enforce per-field local retention defaults with auditable expiry behavior.'
    }
    'NORM-014' = @{
        ThreatAlignment = 'Institutional control'
        FailureIfDowngraded = 'Data sale or broker sharing enables exploitation, discrimination, and coercive profiling by third parties.'
        WhyShouldInsufficient = 'Consent and sharing boundaries are critical trust controls; optional compliance invites monetization pressure and abuse.'
        VerificationMethod = 'Environment: Instrumented build with network inspector enabled. Access to full endpoint list, third-party dependency inventory, consent state toggles, and test account with varied consent states. Action: (1) Enumerate all outbound network destinations via static endpoint list and runtime traffic capture while exercising all essential workflows once. (2) Generate a Data Egress Matrix including destination domain, data categories transmitted, triggering action, and consent prerequisite (if any). (3) Toggle all consent states (opt-in/opt-out combinations) and repeat full essential workflow run while capturing traffic. (4) Compare observed outbound data to documented processor list and privacy documentation. (5) Inspect request payloads for sensitive fields not explicitly documented as shared. Pass Criteria: Every outbound data transmission maps to a documented processor and declared purpose. No sensitive data is transmitted when consent state disallows it. No undocumented third-party endpoints receive user data. Network capture matches documented data-flow inventory. Fail Criteria: Any outbound transmission occurs without documented consent linkage. Undocumented processors receive user data. Sensitive fields appear in payloads outside declared purposes. Consent toggles do not alter data transmission behavior.'
        ReferenceImplStatus = 'Met'
        EvidenceNotes = 'Reference mapping asserts zero third-party access, no ad/analytics trackers, and no data sale pathway.'
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
