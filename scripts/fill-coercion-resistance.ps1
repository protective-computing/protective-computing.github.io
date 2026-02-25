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
    'NORM-022' = @{
        ThreatAlignment = 'Coercion / forced disclosure'
        FailureIfDowngraded = 'Under detention or legal compulsion, users can be forced into plaintext disclosure with no protective operating mode, causing immediate irreversible exposure.'
        WhyShouldInsufficient = 'Coercion events are catastrophic and time-critical; optional controls leave users unprotected in the exact scenario this principle targets.'
        VerificationMethod = 'Run coercion tabletop: assume unlocked-device demand, legal demand, and account-seizure scenarios; verify available protections, what remains hidden, and what is exposed.'
        ReferenceImplStatus = 'Not Met'
        EvidenceNotes = 'Attack scenario: forced unlock and compelled disclosure. Non-coercive fallback: offline local-only mode can reduce future synchronization exposure but does not protect already visible unlocked-session content. Disclosure minimization: at-rest encryption helps only before unlock; once compelled unlock occurs, core content is exposed. To reach Met: add deniability controls and a coercion-safe operating mode that limits plaintext exposure under forced disclosure.'
    }
    'NORM-023' = @{
        ThreatAlignment = 'Institutional control'
        FailureIfDowngraded = 'If system operators can decrypt user data, subpoenas, insider abuse, or platform capture yield bulk plaintext disclosure.'
        WhyShouldInsufficient = 'User-held keys are a hard boundary; making it optional collapses zero-knowledge guarantees under legal or administrative pressure.'
        VerificationMethod = 'Attempt decryption from server-side backup/database using admin credentials only; verify inability to recover plaintext without user key material.'
        ReferenceImplStatus = 'Met'
        EvidenceNotes = 'Attack scenario: compelled server-side disclosure request. Non-coercive fallback: user can withhold passphrase and keep local encrypted copy. Disclosure minimization: server can provide ciphertext only.'
    }
    'NORM-024' = @{
        ThreatAlignment = 'Device seizure'
        FailureIfDowngraded = 'Weak passphrases allow rapid brute-force recovery after confiscation, exposing complete historical records.'
        WhyShouldInsufficient = 'Passphrase strength is not recoverable post-breach; weak defaults create permanent retrospective exposure.'
        VerificationMethod = 'Validate passphrase policy and entropy estimator enforcement; run controlled cracking tests against policy-minimum examples.'
        ReferenceImplStatus = 'Met'
        EvidenceNotes = 'Attack scenario: seized encrypted backup attacked offline. Non-coercive fallback: user can rotate to stronger passphrase and re-encrypt. Disclosure minimization: high-entropy passphrases slow extraction window.'
    }
    'NORM-025' = @{
        ThreatAlignment = 'Device seizure'
        FailureIfDowngraded = 'Fast or obsolete KDFs make offline guessing feasible, turning encrypted stores into recoverable plaintext archives.'
        WhyShouldInsufficient = 'KDF hardness is a mandatory control against commodity cracking rigs; advisory guidance is routinely bypassed for convenience.'
        VerificationMethod = 'Inspect KDF parameters in runtime configuration, benchmark derivation cost, and reject builds that permit MD5/SHA-1 credential derivation.'
        ReferenceImplStatus = 'Met'
        EvidenceNotes = 'Attack scenario: attacker runs GPU/ASIC dictionary attacks on captured ciphertext. Non-coercive fallback: increase Argon2id cost factors for high-risk profiles. Disclosure minimization: slow KDF materially limits guesses per second.'
    }
    'NORM-026' = @{
        ThreatAlignment = 'Institutional control'
        FailureIfDowngraded = 'Any admin backdoor enables unilateral mass disclosure and nullifies user security expectations.'
        WhyShouldInsufficient = 'Backdoor existence is binary; if present at all, coercive capture and insider abuse paths remain open.'
        VerificationMethod = 'Environment: Access to source code (or compiled artifact plus symbol inspection), configuration files, key-derivation routines, and privileged API definitions. Test device with sample encrypted records. Action: (1) Identify all cryptographic key material generation paths (derive, import, rotate, store). (2) Search codebase and configuration for hard-coded keys, embedded private keys, environment-based master secrets, and server-returned decryption keys. (3) Attempt extraction tests: retrieve encrypted record from storage and attempt decryption using only server-accessible secrets (if any); attempt decryption via privileged API endpoint without user-held credential material. (4) Enumerate recovery flows and confirm recovery does not introduce a universal decrypt-capable credential. (5) Confirm decryption requires user-bound key material and cannot be performed solely by backend infrastructure. Pass Criteria: No hard-coded, environment-level, or server-held master key capable of decrypting user records exists. No API endpoint allows record decryption without user-held key material. Recovery flows preserve user-bound key derivation constraints. Encrypted artifacts cannot be decrypted without user credential material. Fail Criteria: Presence of hard-coded or centrally stored master key. Backend infrastructure alone can decrypt user records. Recovery flow introduces universal decrypt capability. Encrypted records decryptable without user-bound secret.'
        ReferenceImplStatus = 'Met'
        EvidenceNotes = 'Attack scenario: operator compelled to decrypt at scale. Non-coercive fallback: user-held key model blocks operator-only decryption. Disclosure minimization: operator can expose metadata or ciphertext but not plaintext.'
    }
    'NORM-027' = @{
        ThreatAlignment = 'State surveillance'
        FailureIfDowngraded = 'Ambiguous threat boundaries produce false safety assumptions and high-risk deployment in contexts the system cannot defend.'
        WhyShouldInsufficient = 'Threat-model clarity is prerequisite for informed consent; non-mandatory disclosure leads to misuse under adversarial conditions.'
        VerificationMethod = 'Environment: Latest release build. Default logging enabled. Test device and test account (if any). Screen recording enabled. Access to app logs, local crash reports, export artifacts, network inspector, and local storage snapshot (IndexedDB dump or app data directory). Action: (1) Identify the spec coercion boundary claims for this requirement (what the system explicitly resists vs does not resist). (2) Execute a Coercion Scenario Matrix (minimum 6 runs) and record outcomes: S1 shoulder-surf/screen-share while navigating privacy controls, exports, and history views; S2 forced show-me-your-data prompt to display historical records quickly; S3 forced export of full history and clinician summary; S4 device seizure with device powered on and app open, attempting retrieval via UI, OS share sheet, and cached previews; S5 device seizure with device powered on and app closed, attempting retrieval via relaunch without network, then filesystem/IndexedDB inspection; S6 network pressure by repeating S3 under packet capture to confirm no telemetry or backup side-channel leakage. (3) For each scenario, capture screenshots/video, exported files, log output, crash artifacts, and storage snapshot before/after. (4) Verify disclosure minimization by enumerating data classes revealed in each scenario (record content, identifiers, metadata, timestamps, derived summaries), whether disclosure required explicit user action, and whether disclosure occurred via logs, exports, cached previews, or storage artifacts. Pass Criteria: Documented coercion boundary matches observed behavior in all scenarios with no surprise disclosures beyond boundary. No sensitive record content is revealed through logs, crash dumps, cached previews, exports, or storage artifacts unless explicitly allowed by boundary and triggered by deliberate user action. Any allowed disclosures are bounded/minimal and auditable in captured artifacts. Fail Criteria: Any scenario reveals sensitive data through unintended channel (logs/exports/caches/storage/network). Observed behavior contradicts documented coercion boundary. Disclosure expands under pressure (e.g., export reveals more than UI, crash logs leak content, caches store plaintext previews).'
        ReferenceImplStatus = 'Met'
        EvidenceNotes = 'Attack scenario: user deploys in active coercion context based on incomplete claims. Non-coercive fallback: documentation directs high-risk users to avoid unsupported threat contexts. Disclosure minimization: explicit limits prevent over-claiming and reduce unsafe reliance.'
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
