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
    'NORM-035' = @{
        ThreatAlignment = 'Institutional control'
        FailureIfDowngraded = 'If engagement/extraction priorities displace essential utility, users lose survival-critical outcomes and become subject to manipulative product incentives.'
        WhyShouldInsufficient = 'Utility-first design is the principle boundary; optional adherence permits business pressure to reintroduce harmful engagement optimization.'
        VerificationMethod = 'Perform feature-subtraction audit against declared essential use cases and verify removal of any non-essential feature does not improve survival-critical task completion while preserving anti-manipulation constraints.'
        ReferenceImplStatus = 'Partial'
        EvidenceNotes = 'Reference mapping states utility-first goals and no engagement optimization, but does not yet publish a formal subtraction-test artifact proving essential-only surface. To reach Met: publish versioned essential-capability subtraction test results.'
    }
    'NORM-037' = @{
        ThreatAlignment = 'Institutional control'
        FailureIfDowngraded = 'Undocumented feature intent enables scope creep, increasing cognitive burden and exploitable non-essential pathways.'
        WhyShouldInsufficient = 'Feature justification must be mandatory to constrain drift toward non-essential complexity.'
        VerificationMethod = 'Environment: A versioned Feature Inventory document (machine-readable preferred) plus a versioned Essential Workflows List and Essential Use-Case Ledger (source of truth). Action: (1) Enumerate all user-facing features and all background behaviors (telemetry, recommendations, nudges, engagement loops, dark patterns) present in the build. (2) For each feature, require a binding link to exactly one of: an Essential Workflow, a Protective Requirement (explicit spec clause), or an Accessibility/Safety obligation. (3) For each feature, record a removal test: what breaks if the feature is removed or disabled? (4) Execute a feature subtraction drill: disable/remove the top 3 non-essential candidates (or simulate via feature flags) and confirm all essential workflows remain intact and user data integrity is preserved. Pass Criteria: 100% of features have a documented linkage to an essential workflow or protective requirement. At least one subtraction drill is executed per release cycle with evidence captured. No feature exists solely for engagement extraction or upsell pressure on essential workflows. Fail Criteria: Any feature lacks linkage. Any essential workflow fails under subtraction drill. Any feature is justified only by engagement, retention, or monetization.'
        ReferenceImplStatus = 'Partial'
        EvidenceNotes = 'Reference mapping documents core use case but lacks a fully versioned feature-justification matrix covering every shipped feature. To reach Met: publish and maintain complete feature-to-need mapping with removal impact notes.'
    }
    'NORM-038' = @{
        ThreatAlignment = 'Institutional control'
        FailureIfDowngraded = 'Dark patterns coerce behavior, impair informed consent, and can force unsafe actions under stress.'
        WhyShouldInsufficient = 'Dark-pattern prevention is binary in high-risk contexts; partial tolerance enables predictable manipulation.'
        VerificationMethod = 'Run dark-pattern audit checklist across onboarding, retention, cancellation, and destructive flows; verify absence of hidden friction, deceptive defaults, and manipulative prompts.'
        ReferenceImplStatus = 'Met'
        EvidenceNotes = 'Reference mapping reports no hidden friction, no manipulative notifications, and no surprise paywalls in audited flows.'
    }
    'NORM-039' = @{
        ThreatAlignment = 'State surveillance'
        FailureIfDowngraded = 'Addictive mechanics increase exposure time, generate excess behavioral data, and create exploitable dependence loops.'
        WhyShouldInsufficient = 'Engagement addiction mechanics are directly counter to user autonomy; they cannot be optionally restricted.'
        VerificationMethod = 'Inspect product behavior for streaks, variable rewards, leaderboards, and FOMO notifications; verify none are present in code/config and runtime UI.'
        ReferenceImplStatus = 'Met'
        EvidenceNotes = 'Reference mapping indicates no gamification loops, no pull-back notifications, and no engagement-maximization mechanisms.'
    }
    'NORM-040' = @{
        ThreatAlignment = 'Institutional control'
        FailureIfDowngraded = 'If success metrics prioritize engagement, roadmap incentives drift toward extraction rather than user outcomes.'
        WhyShouldInsufficient = 'Metric choice governs system behavior; optional outcome metrics are routinely displaced by growth KPIs.'
        VerificationMethod = 'Environment: Access to product planning artifacts for last 2 release cycles (roadmap/PRDs), analytics/KPI definitions, and at least one shipped experiment write-up (A/B test or feature flag). Action: (1) Build a Metric Inventory from dashboards and PRDs listing every primary and secondary success metric with name, definition, and data source. (2) Classify each metric as Outcome/Goal Completion, Engagement/Extraction, or Mixed (requires justification). (3) For each essential workflow (from annex list), verify at least one Outcome/Goal Completion metric is tied directly to it with defined acceptable threshold (pass/fail or target range). (4) Run a Dark-Metric Probe by inspecting shipped UI/flows for engagement mechanics inside essential workflows (nudges, streaks, upsells, nags, continue traps) and confirm whether those mechanics are tracked as success signals. (5) Verify decision precedence: from last 2 cycles, pick 2 roadmap decisions and trace justification metrics, confirming outcome-based justification rather than engagement-based justification. Pass Criteria: Primary success metrics are dominated by Outcome/Goal Completion measures, and each essential workflow has at least one outcome metric with explicit threshold. Engagement metrics, if present, are non-primary, explicitly labeled non-goal, and not used to justify shipping that affects essential workflows. No engagement/extraction mechanics are embedded in essential workflows as measured success drivers. Fail Criteria: Any primary metric is engagement/extraction without outcome linkage. Essential workflows lack outcome metrics or thresholds. Roadmap decisions are justified primarily by engagement metrics or feature adoption without outcome evidence.'
        ReferenceImplStatus = 'Met'
        EvidenceNotes = 'Reference mapping states outcome-oriented success measures and explicitly rejects DAU/time-in-app as primary targets.'
    }
    'NORM-041' = @{
        ThreatAlignment = 'Institutional control'
        FailureIfDowngraded = 'Paywalling essential functions creates coercive access barriers for vulnerable users and undermines protective utility.'
        WhyShouldInsufficient = 'Essential capability access must remain non-discretionary; optional anti-paywall policy invites monetization harm.'
        VerificationMethod = 'Environment: Fresh user profile in Free tier state. No paid entitlements. Network inspector and feature flag visibility if applicable. Action: (1) Define the canonical Essential Workflows List (from spec/annex) as the test plan. (2) Execute each essential workflow end-to-end under Free tier: create/read/update/delete core records, review history, export minimal clinician-ready summary (if defined essential), and access safety-critical settings (privacy controls, deletion, retention). (3) During execution, capture UI state (screenshots/log), network calls (to detect paywall checks), and runtime errors or blocked routes. (4) Attempt deep-link navigation directly to essential workflow endpoints/routes to detect soft gating (paywall only on entry path). (5) Confirm pricing/entitlement matrix matches observed runtime behavior (no mismatch between documented free and actual blocked features). Pass Criteria: Every essential workflow completes in Free tier without paywall, degraded lockout, or hidden gating; no essential endpoint is blocked by entitlement checks (UI or API); entitlement matrix matches observed runtime behavior. Fail Criteria: Any essential workflow is blocked, paywalled, rate-limited to unusability, or requires payment to complete; any essential route is blocked via entitlement enforcement; documented pricing differs from runtime gating.'
        ReferenceImplStatus = 'Met'
        EvidenceNotes = 'Reference mapping indicates no premium paywall on core utility and transparent funding model without data-harvest monetization.'
    }
    'NORM-042' = @{
        ThreatAlignment = 'Institutional control'
        FailureIfDowngraded = 'Without explicit per-principle compliance declaration, weak-area concealment enables misleading claims and unsafe deployment decisions.'
        WhyShouldInsufficient = 'Compliance-level declaration is the auditability backbone; optional disclosure permits selective reporting and trust erosion.'
        VerificationMethod = 'Verify published compliance matrix includes all principles with explicit level assignment and that overall rating resolves to weakest-principle rule.'
        ReferenceImplStatus = 'Met'
        EvidenceNotes = 'Reference implementation publishes principle-by-principle levels and reports overall stance transparently against weakest-principle constraints.'
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
