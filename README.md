# protective-computing.github.io
Official landing page for the Protective Computing discipline — systems design under conditions of human vulnerability.

## Local Preview

Open `index.html` directly in a browser for a quick check, or run a minimal static server:

```powershell
cd protective-computing.github.io
python -m http.server 8080
```

Then browse `http://localhost:8080`.

## Docs Map

- Getting started: `/docs/getting-started.html`
- Specification (v1.0): `/docs/spec/v1.0.html`
- Principles index folder: `/docs/principles/`
- Reference implementation: `/docs/reference-implementation/paintracker-mapping.html`
- Independent review: `/docs/independent-review.html`

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

## Metadata Audit

Run deterministic metadata + sitemap/robots integrity checks:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/metadata-audit.ps1
```

Audit artifacts are written to `scripts/audit-output/`.
The script exits with a non-zero status code when any metadata, sitemap, or robots gate fails.

Policy: all HTML pages MUST include canonical + OG/Twitter baseline tags.

- Stage 3 (verification hardness): CI fails if `WEAK_VERIFICATION_COUNT > 0` (run: `powershell -ExecutionPolicy Bypass -File scripts/semantic-ledger-audit.ps1 -GateStage3`).
