$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$outDir = Join-Path $PSScriptRoot 'audit-output'
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$ts = Get-Date -Format 'yyyyMMdd-HHmmss'
$outFile = Join-Path $outDir "metadata-audit-$ts.txt"

$files = Get-ChildItem -Path $root -Recurse -Filter *.html |
    Where-Object {
        $_.FullName -notlike (Join-Path $outDir '*')
    }

function Get-MetaValue {
    param(
        [string]$Html,
        [string]$Pattern
    )

    $match = [regex]::Match($Html, $Pattern, 'IgnoreCase')
    if ($match.Success) {
        return $match.Groups[1].Value.Trim()
    }

    return ''
}

function Convert-SiteUrlToRelativePath {
    param(
        [string]$Url
    )

    if ([string]::IsNullOrWhiteSpace($Url)) {
        return ''
    }

    $sitePrefix = 'https://protective-computing.github.io'
    if (-not $Url.StartsWith($sitePrefix)) {
        return ''
    }

    $path = $Url.Substring($sitePrefix.Length)
    if ([string]::IsNullOrWhiteSpace($path) -or $path -eq '/') {
        return 'index.html'
    }

    $path = $path.TrimStart('/')
    $path = ($path -split '\?')[0]
    $path = ($path -split '#')[0]
    return $path
}

$rows = foreach ($file in $files) {
    $html = Get-Content -Raw -LiteralPath $file.FullName

    $title = Get-MetaValue -Html $html -Pattern '<title>\s*([^<]+)\s*</title>'
    $desc = Get-MetaValue -Html $html -Pattern '<meta\s+name="description"\s+content="([^"]+)"'
    $canon = Get-MetaValue -Html $html -Pattern '<link\s+rel="canonical"\s+href="([^"]+)"'

    $ogTitle = Get-MetaValue -Html $html -Pattern '<meta\s+property="og:title"\s+content="([^"]+)"'
    $ogDesc = Get-MetaValue -Html $html -Pattern '<meta\s+property="og:description"\s+content="([^"]+)"'
    $ogUrl = Get-MetaValue -Html $html -Pattern '<meta\s+property="og:url"\s+content="([^"]+)"'
    $ogImg = Get-MetaValue -Html $html -Pattern '<meta\s+property="og:image"\s+content="([^"]+)"'

    $twCard = Get-MetaValue -Html $html -Pattern '<meta\s+name="twitter:card"\s+content="([^"]+)"'
    $twTitle = Get-MetaValue -Html $html -Pattern '<meta\s+name="twitter:title"\s+content="([^"]+)"'
    $twDesc = Get-MetaValue -Html $html -Pattern '<meta\s+name="twitter:description"\s+content="([^"]+)"'
    $twImg = Get-MetaValue -Html $html -Pattern '<meta\s+name="twitter:image"\s+content="([^"]+)"'

    $descMatch = ($desc -ne '') -and ($desc -eq $ogDesc) -and ($desc -eq $twDesc)
    $titleMatch = ($title -ne '') -and ($title -eq $ogTitle) -and ($title -eq $twTitle)
    $canonicalPresent = ($canon -ne '')
    $canonicalPathExists = $false
    if ($canonicalPresent) {
        $canonicalRelativePath = Convert-SiteUrlToRelativePath -Url $canon
        if ($canonicalRelativePath -ne '') {
            $canonicalLocalPath = Join-Path $root ($canonicalRelativePath.Replace('/', '\\'))
            $canonicalPathExists = Test-Path -LiteralPath $canonicalLocalPath
        }
    }
    $ogUrlMatch = ($canonicalPresent -and ($canon -eq $ogUrl) -and ($canon -match '^https?://'))
    $imgAbsolute = (($ogImg -match '^https?://') -and ($twImg -match '^https?://'))
    $twCardPresent = ($twCard -ne '')

    $brokenMeta =
        ($title -eq '') -or
        ($desc -eq '') -or
        ($canon -eq '') -or
        ($ogTitle -eq '') -or
        ($ogDesc -eq '') -or
        ($ogUrl -eq '')

    [pscustomobject]@{
        File = $file.FullName.Replace($root + '\\', '').Replace('\\', '/')
        TITLE = $title
        DESCRIPTION = $desc
        CANONICAL_HREF = $canon
        OG_TITLE = $ogTitle
        OG_DESCRIPTION = $ogDesc
        OG_URL = $ogUrl
        OG_IMAGE = $ogImg
        TW_CARD_VALUE = $twCard
        TW_TITLE = $twTitle
        TW_DESCRIPTION = $twDesc
        TW_IMAGE = $twImg
        DESC_MATCH = $descMatch
        TITLE_MATCH = $titleMatch
        CANONICAL = $canonicalPresent
        CANONICAL_PATH_EXISTS = $canonicalPathExists
        OG_URL_MATCH = $ogUrlMatch
        IMG_ABSOLUTE = $imgAbsolute
        TW_CARD = $twCardPresent
        BROKEN_META = $brokenMeta
    }
}

$failRows = $rows | Where-Object {
    -not $_.DESC_MATCH -or
    -not $_.TITLE_MATCH -or
    -not $_.CANONICAL -or
    -not $_.CANONICAL_PATH_EXISTS -or
    -not $_.OG_URL_MATCH -or
    -not $_.IMG_ABSOLUTE -or
    -not $_.TW_CARD -or
    $_.BROKEN_META
} | Sort-Object -Property File
$failureCount = [int]$failRows.Count

$sitemapPath = Join-Path $root 'sitemap.xml'
$sitemapUrls = @()
if (Test-Path -LiteralPath $sitemapPath) {
    $sitemapXml = Get-Content -Raw -LiteralPath $sitemapPath
    $sitemapMatches = [regex]::Matches($sitemapXml, '<loc>\s*([^<]+)\s*</loc>', 'IgnoreCase')
    foreach ($match in $sitemapMatches) {
        $sitemapUrls += $match.Groups[1].Value.Trim()
    }
}

$ogUrls = $rows | ForEach-Object { $_.OG_URL } | Where-Object { $_ -ne '' } | Sort-Object -Unique

$ogUrlMissingInSitemap = @(
    $ogUrls | Where-Object { $sitemapUrls -notcontains $_ }
)

$sitemapUrlWithoutLocalFile = @()
foreach ($url in $sitemapUrls) {
    $relativePath = Convert-SiteUrlToRelativePath -Url $url
    if ($relativePath -eq '') {
        $sitemapUrlWithoutLocalFile += "$url -> [non-site URL or unparsable]"
        continue
    }

    $localPath = Join-Path $root ($relativePath.Replace('/', '\\'))
    if (-not (Test-Path -LiteralPath $localPath)) {
        $sitemapUrlWithoutLocalFile += "$url -> $relativePath"
    }
}

$robotsPath = Join-Path $root 'robots.txt'
$robotsLogoBlocked = $false
if (Test-Path -LiteralPath $robotsPath) {
    $robotsText = Get-Content -Raw -LiteralPath $robotsPath
    if ([regex]::IsMatch($robotsText, '^\s*Disallow:\s*/assets/logo\.png\s*$', 'IgnoreCase, Multiline')) {
        $robotsLogoBlocked = $true
    }
}

$fullTable = ($rows | Sort-Object -Property File | Select-Object File, DESC_MATCH, TITLE_MATCH, CANONICAL, CANONICAL_PATH_EXISTS, OG_URL_MATCH, IMG_ABSOLUTE, TW_CARD, BROKEN_META | Format-Table -AutoSize | Out-String -Width 4096)
$failTable = if ($failRows.Count -gt 0) {
    ($failRows | Select-Object File, DESC_MATCH, TITLE_MATCH, CANONICAL, CANONICAL_PATH_EXISTS, OG_URL_MATCH, IMG_ABSOLUTE, TW_CARD, BROKEN_META | Format-Table -AutoSize | Out-String -Width 4096)
} else {
    '(none)'
}

$ogMissingSection = if ($ogUrlMissingInSitemap.Count -gt 0) {
    ($ogUrlMissingInSitemap | Sort-Object | Out-String -Width 4096)
} else {
    '(none)'
}

$sitemapMissingSection = if ($sitemapUrlWithoutLocalFile.Count -gt 0) {
    ($sitemapUrlWithoutLocalFile | Sort-Object | Out-String -Width 4096)
} else {
    '(none)'
}

$report = @()
$report += 'FULL TABLE:'
$report += $fullTable.TrimEnd()
$report += ''
$report += 'FAILURES ONLY:'
$report += $failTable.TrimEnd()
$report += ''
$report += 'SITEMAP PARITY CHECK:'
$report += 'OG_URL values missing from sitemap.xml:'
$report += $ogMissingSection.TrimEnd()
$report += ''
$report += 'sitemap.xml URLs without local file mapping:'
$report += $sitemapMissingSection.TrimEnd()
$report += ''
$report += 'ROBOTS CHECK:'
$report += ("Disallow /assets/logo.png present: {0}" -f $robotsLogoBlocked)
$report += ''
$sitemapFailureCount = [int]($ogUrlMissingInSitemap.Count + $sitemapUrlWithoutLocalFile.Count)
$robotsFailureCount = if ($robotsLogoBlocked) { 1 } else { 0 }
$totalFailureCount = [int]($failureCount + $sitemapFailureCount + $robotsFailureCount)
$report += ("METADATA FAILURE COUNT: {0}" -f $failureCount)
$report += ("SITEMAP FAILURE COUNT: {0}" -f $sitemapFailureCount)
$report += ("ROBOTS FAILURE COUNT: {0}" -f $robotsFailureCount)
$report += ''
$report += ("TOTAL PAGES: {0}" -f $rows.Count)
$report += ("FAILURE COUNT: {0}" -f $totalFailureCount)

$report -join "`r`n" | Set-Content -LiteralPath $outFile -Encoding UTF8

Write-Output "Wrote: $outFile"

if ($totalFailureCount -gt 0) {
    exit 1
}

exit 0
