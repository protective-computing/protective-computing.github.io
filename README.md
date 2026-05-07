# protective-computing.github.io
Official landing page for the Protective Computing discipline — systems design under conditions of human vulnerability.

## Primary citations

- Canon (Structural Map) DOI: https://doi.org/10.5281/zenodo.18887610
- Theory (Overton Framework v1.3) DOI: https://doi.org/10.5281/zenodo.18688516

## Local Preview

Open `index.html` directly in a browser for a quick check, or run a minimal static server:

```powershell
cd protective-computing.github.io
python -m http.server 8080
```

Then browse `http://localhost:8080`.

## Docs Map

- Audit this site: `/docs/audit-this-site.html`
- Legitimacy & evidence: `/docs/legitimacy.html`
- Standards crosswalks: `/docs/standards-crosswalks.html`
- Standards crosswalk annexes: `/docs/standards-crosswalk-annexes.html`
- Example framework crosswalk page: `/docs/crosswalks/nist-privacy-framework.html`
- Getting started: `/docs/getting-started.html`
- Specification (v1.0): `/docs/spec/v1.0.html`
- Principles index folder: `/docs/principles/`
- Formal threat models: `/THREAT_MODELS.md`
- Implementation patterns: `/IMPLEMENTATION_PATTERNS.md`
- Compliance & audit matrix: `/COMPLIANCE_AUDIT_MATRIX.md`
- Audit evidence index: `/AUDIT_EVIDENCE.md`
- Audit artifact draft: `/AUDIT_ARTIFACT_DRAFT.md`
- Remediation artifact list: `/REMEDIATION_ARTIFACT_LIST.md`
- Coercion boundary matrix: `/COERCION_BOUNDARY_MATRIX.md`
- Coercion-safe mode design brief: `/COERCION_SAFE_MODE_DESIGN_BRIEF.md`
- Coercion scenario evidence packet: `/COERCION_SCENARIO_EVIDENCE_PACKET.md`
- Duress mode requirements checklist: `/DURESS_MODE_REQUIREMENTS_CHECKLIST.md`
- Duress mode implementation spec: `/DURESS_MODE_IMPLEMENTATION_SPEC.md`
- Duress mode routing design: `/DURESS_MODE_ROUTING_DESIGN.md`
- Degraded mode remediation matrix: `/DEGRADED_MODE_REMEDIATION_MATRIX.md`
- Degraded mode requirements checklist: `/DEGRADED_MODE_REQUIREMENTS_CHECKLIST.md`
- Degraded mode implementation spec: `/DEGRADED_MODE_IMPLEMENTATION_SPEC.md`
- Local retention default spec: `/LOCAL_RETENTION_DEFAULT_SPEC.md`
- Backup service metadata retention policy: `/BACKUP_SERVICE_METADATA_RETENTION_POLICY.md`
- Retention enforcement verification report: `/RETENTION_ENFORCEMENT_VERIFICATION_REPORT.md`
- Local Authority operating profile: `/LOCAL_AUTHORITY_OPERATING_PROFILE.md`
- Offline parity and sync spec: `/OFFLINE_PARITY_AND_SYNC_SPEC.md`
- Reversibility boundary table: `/REVERSIBILITY_BOUNDARY_TABLE.md`
- Field justification ledger: `/FIELD_JUSTIFICATION_LEDGER.md`
- Feature justification matrix: `/FEATURE_JUSTIFICATION_MATRIX.md`
- Essential utility subtraction report: `/ESSENTIAL_UTILITY_SUBTRACTION_REPORT.md`
- Retention policy table: `/RETENTION_POLICY_TABLE.md`
- Independent review checklist: `/INDEPENDENT_REVIEW_CHECKLIST.md`
- v1.1 planning issue templates: `/V1_1_ISSUE_TEMPLATES.md`
- Reference implementation: `/docs/reference-implementation/paintracker-mapping.html`
- PainTracker reference packet: `/docs/reference-implementation/paintracker-reference-packet.html`
- External Review 0001 example: `/docs/reviews/external-review-0001-paintracker-reference-packet.html`
- Independent review: `/docs/independent-review.html`
- Boundary page: `/docs/what-protective-computing-is-not.html`
- External review packet template: `/docs/external-review-packet-template.html`
- RFC process: `/docs/rfc-process.html`
- Release history: `/docs/release-history.html`

## Contributing

Use GitHub Issues for suggestions, critiques, and corrections.

Suggested labels:
- `spec-bug`
- `spec-gap`
- `spec-disagreement`

## Release Discipline

- `v1.x` is stable and backward-compatible for compliance claims.
- `v1.1+` incorporates review-driven clarifications and implementation guidance.
- `v2.0` is reserved for paradigm-level changes (new principles or fundamental threat-model expansion).
- Frozen baseline: `v1.0.0` tag marks the stable reference state for reproducible audits; subsequent hardening/docs updates are tracked as `v1.1+` guidance.

## Metadata Audit

Run deterministic metadata + sitemap/robots integrity checks:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/metadata-audit.ps1
```

Audit artifacts are written to `scripts/audit-output/`.
The script exits with a non-zero status code when any metadata, sitemap, or robots gate fails.

Policy: all HTML pages MUST include canonical + OG/Twitter baseline tags.

- Stage 3 (verification hardness): CI fails if `WEAK_VERIFICATION_COUNT > 0` (run: `powershell -ExecutionPolicy Bypass -File scripts/semantic-ledger-audit.ps1 -GateStage3`).
