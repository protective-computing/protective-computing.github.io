# AUDIT_EVIDENCE.md

## Purpose
Operational index for repeatable audit evidence collection and verification.

## Canonical Inputs
- Specification: `/docs/spec/v1.0.html`
- MUST justifications annex: `/docs/spec/v1.0-must-justifications.html`
- Threat scenarios: `/THREAT_MODELS.md`
- Implementation blueprints: `/IMPLEMENTATION_PATTERNS.md`
- Compliance mapping: `/COMPLIANCE_AUDIT_MATRIX.md`

## CI Enforcement Sources
- Workflow: `/.github/workflows/audit.yml`
- Stage 1 audit script: `/scripts/metadata-audit.ps1`
- Stage 2/3 audit script: `/scripts/semantic-ledger-audit.ps1`

## Required Pass Signals
- Stage 1: metadata/sitemap/robots audit exits 0
- Stage 2: no blank threat/failure fields; gate exits 0
- Stage 3: `WEAK_VERIFICATION_COUNT=0`; gate exits 0

## Local Reproduction Commands
```powershell
powershell -ExecutionPolicy Bypass -File scripts/metadata-audit.ps1
powershell -ExecutionPolicy Bypass -File scripts/semantic-ledger-audit.ps1 -GateStage2
powershell -ExecutionPolicy Bypass -File scripts/semantic-ledger-audit.ps1 -GateStage3
```

## Expected Semantic Output Anchors
- `WEAK_VERIFICATION_COUNT=<int>`
- `Stage 2 gate passed.`
- `Stage 3 gate passed.`

## Artifact Locations
- Generated audit artifacts: `/scripts/audit-output/`
- Typical files:
  - `metadata-audit-YYYYMMDD-HHMMSS.txt`
  - `must-ledger-YYYYMMDD-HHMMSS.csv`
  - `must-ledger-deduped-YYYYMMDD-HHMMSS.csv`
  - `must-ledger-dupes-triage-YYYYMMDD-HHMMSS.txt`

## Evidence Packaging Checklist
1. Include latest Stage 1 artifact text file.
2. Include latest deduped ledger CSV used by Stage 2/3.
3. Include semantic gate output showing `WEAK_VERIFICATION_COUNT=0`.
4. Include CI run URL proving workflow execution on target commit.

## Reviewer Note
If local and CI outcomes diverge, CI is authoritative for merge decisions; investigate environment and artifact freshness.
