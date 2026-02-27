Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$baseUrl = 'https://protective-computing.github.io'

$entries = @(
  @{ loc = "$baseUrl/"; file = 'index.html'; changefreq = 'weekly'; priority = '1.0' },

  @{ loc = "$baseUrl/docs/getting-started.html"; file = 'docs/getting-started.html'; changefreq = 'monthly'; priority = '0.9' },
  @{ loc = "$baseUrl/docs/stability-assumption.html"; file = 'docs/stability-assumption.html'; changefreq = 'monthly'; priority = '0.9' },
  @{ loc = "$baseUrl/docs/offline-first-health-architecture.html"; file = 'docs/offline-first-health-architecture.html'; changefreq = 'monthly'; priority = '0.9' },
  @{ loc = "$baseUrl/docs/trauma-informed-software-patterns.html"; file = 'docs/trauma-informed-software-patterns.html'; changefreq = 'monthly'; priority = '0.9' },
  @{ loc = "$baseUrl/docs/spec/v1.0.html"; file = 'docs/spec/v1.0.html'; changefreq = 'yearly'; priority = '0.95' },
  @{ loc = "$baseUrl/docs/spec/v1.0-must-justifications.html"; file = 'docs/spec/v1.0-must-justifications.html'; changefreq = 'monthly'; priority = '0.94' },
  @{ loc = "$baseUrl/docs/reference-implementation/paintracker-mapping.html"; file = 'docs/reference-implementation/paintracker-mapping.html'; changefreq = 'monthly'; priority = '0.92' },
  @{ loc = "$baseUrl/docs/independent-review.html"; file = 'docs/independent-review.html'; changefreq = 'monthly'; priority = '0.93' },

  # Directory URL resolves to docs/principles/index.html on GitHub Pages.
  @{ loc = "$baseUrl/docs/principles/"; file = 'docs/principles/index.html'; changefreq = 'monthly'; priority = '0.9' },

  @{ loc = "$baseUrl/docs/principles/reversibility.html"; file = 'docs/principles/reversibility.html'; changefreq = 'monthly'; priority = '0.85' },
  @{ loc = "$baseUrl/docs/principles/exposure-minimization.html"; file = 'docs/principles/exposure-minimization.html'; changefreq = 'monthly'; priority = '0.85' },
  @{ loc = "$baseUrl/docs/principles/local-authority.html"; file = 'docs/principles/local-authority.html'; changefreq = 'monthly'; priority = '0.85' },
  @{ loc = "$baseUrl/docs/principles/coercion-resistance.html"; file = 'docs/principles/coercion-resistance.html'; changefreq = 'monthly'; priority = '0.85' },
  @{ loc = "$baseUrl/docs/principles/degraded-functionality.html"; file = 'docs/principles/degraded-functionality.html'; changefreq = 'monthly'; priority = '0.85' },
  @{ loc = "$baseUrl/docs/principles/essential-utility.html"; file = 'docs/principles/essential-utility.html'; changefreq = 'monthly'; priority = '0.85' },

  # Important published artifact.
  @{ loc = "$baseUrl/PLS_RUBRIC_v1_0_rc1.pdf"; file = 'PLS_RUBRIC_v1_0_rc1.pdf'; changefreq = 'yearly'; priority = '0.6' }
)

function Get-LastMod([string] $path) {
  if (-not (Test-Path -LiteralPath $path)) {
    return $null
  }

  $value = (git log -1 --format=%cI -- $path 2>$null)
  if (-not $value) {
    return $null
  }
  return $value.Trim()
}

function XmlEscape([string] $value) {
  if ($null -eq $value) { return '' }
  return [System.Security.SecurityElement]::Escape($value)
}

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add('<?xml version="1.0" encoding="UTF-8"?>')
$lines.Add('<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">')

foreach ($entry in $entries) {
  $lastMod = Get-LastMod -path $entry.file
  if (-not $lastMod) {
    # If a file is missing, skip it rather than emitting stale/incorrect metadata.
    continue
  }

  $lines.Add('  <url>')
  $lines.Add("    <loc>$(XmlEscape $entry.loc)</loc>")
  $lines.Add("    <lastmod>$(XmlEscape $lastMod)</lastmod>")
  $lines.Add("    <changefreq>$(XmlEscape $entry.changefreq)</changefreq>")
  $lines.Add("    <priority>$(XmlEscape $entry.priority)</priority>")
  $lines.Add('  </url>')
}

$lines.Add('</urlset>')

$outPath = Join-Path $PSScriptRoot '..\sitemap.xml'
Set-Content -LiteralPath $outPath -Value $lines -Encoding UTF8
Write-Host "Wrote sitemap: $outPath"
