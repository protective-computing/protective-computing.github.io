param(
    [string]$CsvPath = '',
    [switch]$GateStage2,
    [switch]$GateStage3
)

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$auditDir = Join-Path $PSScriptRoot 'audit-output'

if ([string]::IsNullOrWhiteSpace($CsvPath)) {
    $latest = Get-ChildItem -Path $auditDir -Filter 'must-ledger-deduped-*.csv' |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    if ($null -eq $latest) {
        $latest = Get-ChildItem -Path $auditDir -Filter 'must-ledger-*.csv' |
            Sort-Object LastWriteTime -Descending |
            Select-Object -First 1
    }

    if ($null -eq $latest) {
        throw 'No must-ledger CSV files found in scripts/audit-output.'
    }

    $CsvPath = $latest.FullName
}

if (-not (Test-Path -LiteralPath $CsvPath)) {
    throw "CSV not found: $CsvPath"
}

$csv = Import-Csv -LiteralPath $CsvPath

$normalized = $csv | ForEach-Object {
    $text = $_.NormativeText
    $clean = (($text.ToLower() -replace '[^a-z0-9 ]', '') -replace '\s+', ' ').Trim()

    [pscustomobject]@{
        ID = $_.ID
        Text = $text
        Normalized = $clean
    }
}

$dupes = $normalized |
    Group-Object Normalized |
    Where-Object { $_.Count -gt 1 }

$duplicateRows = ($dupes | ForEach-Object { $_.Count } | Measure-Object -Sum).Sum
if ($null -eq $duplicateRows) {
    $duplicateRows = 0
}

$blankVerification = @($csv | Where-Object { [string]::IsNullOrWhiteSpace($_.VerificationMethod) }).Count
$blankThreatAlignment = @($csv | Where-Object { [string]::IsNullOrWhiteSpace($_.ThreatAlignment) }).Count
$blankFailureIfDowngraded = @($csv | Where-Object { [string]::IsNullOrWhiteSpace($_.FailureIfDowngraded) }).Count

$allowedThreatTags = @(
    'State surveillance',
    'Institutional control',
    'Network tampering',
    'Device seizure',
    'Coercion / forced disclosure'
)

$allowedStatuses = @('Met', 'Partial', 'Not Met', 'N/A')

$rowsWithThreat = $csv | Where-Object { -not [string]::IsNullOrWhiteSpace($_.ThreatAlignment) }
$invalidThreatTags = @(
    $rowsWithThreat | Where-Object { $allowedThreatTags -notcontains $_.ThreatAlignment }
)

$rowsWithStatus = $csv | Where-Object { -not [string]::IsNullOrWhiteSpace($_.ReferenceImplStatus) }
$invalidStatuses = @(
    $rowsWithStatus | Where-Object { $allowedStatuses -notcontains $_.ReferenceImplStatus }
)

$partialWithoutUpgradePath = @(
    $csv | Where-Object {
        $_.ReferenceImplStatus -eq 'Partial' -and
        ($_.EvidenceNotes -notmatch 'To reach Met:')
    }
)

$candidateForDowngrade = @(
    $csv | Where-Object {
        -not [string]::IsNullOrWhiteSpace($_.NormativeText) -and
        [string]::IsNullOrWhiteSpace($_.VerificationMethod)
    }
)

$actionableVerificationPattern = '(?i)(test|execute|run|inspect|measure|verify|attempt|throttle|inject|disable|expire|query|trace|benchmark|simulate|audit\s+checkpoint)'

$weakVerificationFindings = New-Object System.Collections.Generic.List[object]
foreach ($row in $csv) {
    $method = if ($null -eq $row.VerificationMethod) { '' } else { $row.VerificationMethod.Trim() }
    if ([string]::IsNullOrWhiteSpace($method)) {
        continue
    }

    $reasons = New-Object System.Collections.Generic.List[string]

    if ($method -match '(?i)\b(review|ensure|confirm|audit)\b' -and $method -notmatch $actionableVerificationPattern) {
        $reasons.Add('uses review/confirm language without explicit executable test step') | Out-Null
    }

    if ($row.Section -match '4\.3 Local Authority' -and $method -match '(?i)\b(admin|privileged|root|operator|backend\s+admin|database\s+admin)\b') {
        $reasons.Add('depends on privileged backend access for a Local Authority requirement') | Out-Null
    }

    if ($method -match '(?i)\b(non[- ]?recoverable|irrecoverable|prove\s+deletion\s+from\s+physical\s+media|forensic\s+destruction)\b') {
        $reasons.Add('implies unverifiable or out-of-scope proof language') | Out-Null
    }

    if ($method -match '(?i)^\s*(audit|review)\b' -and $method -notmatch '(?i)\b(pass|fail|threshold|tolerance|criteria|must\s+be|less\s+than|greater\s+than)\b') {
        $reasons.Add('starts as audit/review without explicit pass/fail criteria') | Out-Null
    }

    if ($reasons.Count -gt 0) {
        $weakVerificationFindings.Add([pscustomobject]@{
            ID = $row.ID
            Section = $row.Section
            VerificationMethod = $method
            Reason = ($reasons -join '; ')
        }) | Out-Null
    }
}

Write-Output 'SUMMARY:'
Write-Output ("LedgerCsv                 : {0}" -f $CsvPath)
Write-Output ("TotalRows                 : {0}" -f @($csv).Count)
Write-Output ("DuplicateGroups           : {0}" -f @($dupes).Count)
Write-Output ("DuplicateRows             : {0}" -f $duplicateRows)
Write-Output ("BlankVerification         : {0}" -f $blankVerification)
Write-Output ("BlankThreatAlignment      : {0}" -f $blankThreatAlignment)
Write-Output ("BlankFailureIfDowngraded  : {0}" -f $blankFailureIfDowngraded)
Write-Output ("InvalidThreatTags         : {0}" -f @($invalidThreatTags).Count)
Write-Output ("InvalidStatuses           : {0}" -f @($invalidStatuses).Count)
Write-Output ("PartialWithoutUpgradePath : {0}" -f @($partialWithoutUpgradePath).Count)
Write-Output ("CandidateForDowngrade     : {0}" -f @($candidateForDowngrade).Count)
Write-Output "WEAK_VERIFICATION_COUNT   : $($weakVerificationFindings.Count)"
Write-Output "WEAK_VERIFICATION_COUNT=$($weakVerificationFindings.Count)"

Write-Output 'DUPLICATE GROUPS:'
if (@($dupes).Count -eq 0) {
    Write-Output '(none)'
}
else {
    $dupes |
        ForEach-Object {
            [pscustomobject]@{
                Count = $_.Count
                IDs = ($_.Group | ForEach-Object { $_.ID }) -join ', '
                Sample = $_.Group[0].Text
            }
        } |
        Format-Table -AutoSize
}

Write-Output 'VOCAB CHECKS:'
Write-Output "Invalid threat tags: $(@($invalidThreatTags).Count)"
if (@($invalidThreatTags).Count -gt 0) {
    $invalidThreatTags | Select-Object ID, ThreatAlignment | Format-Table -AutoSize
}

Write-Output "Invalid statuses: $(@($invalidStatuses).Count)"
if (@($invalidStatuses).Count -gt 0) {
    $invalidStatuses | Select-Object ID, ReferenceImplStatus | Format-Table -AutoSize
}

Write-Output "Partial rows missing upgrade path: $(@($partialWithoutUpgradePath).Count)"
if (@($partialWithoutUpgradePath).Count -gt 0) {
    $partialWithoutUpgradePath | Select-Object ID, ReferenceImplStatus, EvidenceNotes | Format-Table -AutoSize
}

if ($blankThreatAlignment -gt 0) {
    Write-Warning "ANNEX INCOMPLETE - $blankThreatAlignment normative requirements lack threat justification."
}

Write-Output "Candidate rows for downgrade review (blank verification): $(@($candidateForDowngrade).Count)"

Write-Output "WEAK_VERIFICATION_COUNT: $($weakVerificationFindings.Count)"
if ($weakVerificationFindings.Count -gt 0) {
    Write-Output 'WEAK VERIFICATION FINDINGS:'
    $weakVerificationFindings | Select-Object ID, Reason | Format-Table -AutoSize
}

if ($GateStage2) {
    if ($blankThreatAlignment -gt 0 -or $blankFailureIfDowngraded -gt 0) {
        Write-Error "Stage 2 gate failed: BlankThreatAlignment=$blankThreatAlignment, BlankFailureIfDowngraded=$blankFailureIfDowngraded"
        exit 1
    }

    Write-Output 'Stage 2 gate passed.'
}

if ($GateStage3) {
    if ($weakVerificationFindings.Count -gt 0) {
        Write-Error "Stage 3 gate failed: WEAK_VERIFICATION_COUNT=$($weakVerificationFindings.Count)"
        exit 1
    }

    Write-Output 'Stage 3 gate passed.'
}
