$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$specPath = Join-Path $root 'docs\spec\v1.0.html'
$annexPath = Join-Path $root 'docs\spec\v1.0-must-justifications.html'
$outDir = Join-Path $PSScriptRoot 'audit-output'
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$csvPath = Join-Path $outDir "must-ledger-$timestamp.csv"
$rowsPath = Join-Path $outDir "must-ledger-rows-$timestamp.html"

function Strip-Html {
    param(
        [string]$Html
    )

    if ([string]::IsNullOrWhiteSpace($Html)) {
        return ''
    }

    $text = [regex]::Replace($Html, '<[^>]+>', ' ')
    $text = [System.Net.WebUtility]::HtmlDecode($text)
    $text = [regex]::Replace($text, '\s+', ' ').Trim()
    return $text
}

function Escape-Attr {
    param(
        [string]$Text
    )

    if ($null -eq $Text) {
        return ''
    }

    return [System.Net.WebUtility]::HtmlEncode($Text)
}

$lines = Get-Content -LiteralPath $specPath -Encoding UTF8

$currentH2Id = ''
$currentH2Text = ''
$currentH3Text = ''
$normativeIndex = 0
$records = New-Object System.Collections.Generic.List[object]

for ($i = 0; $i -lt $lines.Count; $i++) {
    $line = $lines[$i]

    $h2Match = [regex]::Match($line, '<h2\s+id="([^"]+)">\s*([^<]+)\s*</h2>', 'IgnoreCase')
    if ($h2Match.Success) {
        $currentH2Id = $h2Match.Groups[1].Value.Trim()
        $currentH2Text = Strip-Html -Html $h2Match.Groups[2].Value
        $currentH3Text = ''
    }

    $h3Match = [regex]::Match($line, '<h3[^>]*>\s*([^<]+)\s*</h3>', 'IgnoreCase')
    if ($h3Match.Success) {
        $currentH3Text = Strip-Html -Html $h3Match.Groups[1].Value
    }

    $keywordMatches = [regex]::Matches($line, '<span\s+class="normative-keyword">\s*(MUST NOT|MUST)\s*</span>', 'IgnoreCase')
    if ($keywordMatches.Count -eq 0) {
        continue
    }

    if ($currentH2Id -eq 'sec1') {
        continue
    }

    $containerHtml = ''
    $liMatch = [regex]::Match($line, '<li[^>]*>(.*?)</li>', 'IgnoreCase')
    if ($liMatch.Success) {
        $containerHtml = $liMatch.Groups[1].Value
    }

    if ($containerHtml -eq '') {
        $pMatch = [regex]::Match($line, '<p[^>]*>(.*?)</p>', 'IgnoreCase')
        if ($pMatch.Success) {
            $containerHtml = $pMatch.Groups[1].Value
        }
    }

    if ($containerHtml -eq '') {
        $containerHtml = $line
    }

    $normativeText = Strip-Html -Html $containerHtml

    foreach ($keywordMatch in $keywordMatches) {
        $keyword = $keywordMatch.Groups[1].Value.ToUpperInvariant()
        $normativeIndex++

        $idValue = ('NORM-{0:D3}' -f $normativeIndex)
        $anchor = if ($currentH2Id -ne '') { $currentH2Id } else { 'sec4' }
        $specHref = "/docs/spec/v1.0.html#$anchor"
        $locationText = if ($currentH3Text -ne '') {
            "$currentH2Text | $currentH3Text"
        } else {
            $currentH2Text
        }

        $records.Add([pscustomobject]@{
            ID = $idValue
            Keyword = $keyword
            Section = $locationText
            Anchor = $anchor
            SpecLocationHref = $specHref
            NormativeText = $normativeText
            ThreatAlignment = ''
            FailureIfDowngraded = ''
            WhyShouldInsufficient = ''
            VerificationMethod = ''
            ReferenceImplStatus = 'N/A'
            EvidenceNotes = ''
            TargetVersion = 'v1.0'
            SourceLine = ($i + 1)
        }) | Out-Null
    }
}

$records | Export-Csv -LiteralPath $csvPath -NoTypeInformation -Encoding UTF8

$htmlRows = New-Object System.Collections.Generic.List[string]
foreach ($record in $records) {
    $idText = Escape-Attr -Text $record.ID
    $keywordText = Escape-Attr -Text $record.Keyword
    $sectionText = Escape-Attr -Text $record.Section
    $hrefText = Escape-Attr -Text $record.SpecLocationHref
    $normativeText = Escape-Attr -Text $record.NormativeText
    $targetVersion = Escape-Attr -Text $record.TargetVersion
    $status = Escape-Attr -Text $record.ReferenceImplStatus

    $row = @"
      <tr>
        <td><code>$idText</code></td>
        <td><code>$keywordText</code></td>
        <td>$sectionText (<a href="$hrefText">link</a>)</td>
        <td>$normativeText</td>
        <td>-</td>
        <td>-</td>
        <td>-</td>
        <td>-</td>
        <td>$status</td>
        <td>Source line $($record.SourceLine)</td>
        <td>$targetVersion</td>
      </tr>
"@
    $htmlRows.Add($row.TrimEnd()) | Out-Null
}

$rowsContent = ($htmlRows -join "`r`n")
$rowsContent | Set-Content -LiteralPath $rowsPath -Encoding UTF8

$annex = Get-Content -Raw -LiteralPath $annexPath -Encoding UTF8
$annexUpdated = [regex]::Replace(
    $annex,
    '<tbody>[\s\S]*?</tbody>',
    "<tbody>`r`n$rowsContent`r`n    </tbody>",
    'IgnoreCase'
)
Set-Content -LiteralPath $annexPath -Value $annexUpdated -Encoding UTF8

Write-Output "Generated ledger entries: $($records.Count)"
Write-Output "CSV: $csvPath"
Write-Output "HTML rows: $rowsPath"
Write-Output "Updated annex: $annexPath"
