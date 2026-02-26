# IMPLEMENTATION_PATTERNS.md

## Purpose
This document provides implementation blueprints for building systems to the Protective Computing specification.
It is written for engineers and auditors who need reproducible architecture patterns.

## Design Goals
1. Keep essential workflows operable under degraded and offline conditions.
2. Bound and minimize disclosure across UI, storage, network, and exports.
3. Guarantee reversibility where declared and explicit irreversibility where required.
4. Preserve local authority independent of institutional availability.

## Pattern 1: Offline-First State Authority
### Problem
Essential workflow execution blocks on network availability.

### Pattern
- Use local durable storage as source of truth for essential records.
- Maintain operation log (`oplog`) with deterministic IDs and timestamps.
- Use async sync queue for reconciliation; never block local commit on remote acknowledgement.

### Required Controls
- Local write path succeeds without network.
- Sync retries are idempotent and bounded.
- Conflict resolution policy is explicit and testable.

### Verification Hook
- Execute offline/intermittent/online matrix and verify identical essential-path completion semantics.

## Pattern 2: Reversible Transition Ledger
### Problem
Destructive state changes become irreversible by implementation drift.

### Pattern
- Define transition inventory with fields:
  - `transition_id`
  - `trigger`
  - `reversible` (`true/false`)
  - `recovery_path`
  - `window`
- Enforce inventory updates as part of release process.

### Required Controls
- Reversible transitions must have executable restore paths.
- Irreversible transitions must require explicit user acknowledgment before execution.

### Verification Hook
- Transition-by-transition restore tests with before/after state snapshots.

## Pattern 3: Data Egress Matrix Enforcement
### Problem
Undocumented or non-consensual outbound transmission appears over time.

### Pattern
- Maintain machine-readable egress matrix with:
  - destination
  - data classes
  - trigger action
  - consent prerequisite
  - declared purpose
- Fail release if runtime capture diverges from matrix.

### Required Controls
- Consent toggles deterministically change transmission behavior.
- New endpoint introduction requires matrix update.

### Verification Hook
- Capture full essential workflow traffic across consent states and diff against matrix.

## Pattern 4: Coercion-Bounded UI/Export Surfaces
### Problem
Forced interaction reveals more data than documented threat boundaries permit.

### Pattern
- Separate essential operational views from high-disclosure historical views.
- Require explicit user action for high-volume export surfaces.
- Prevent silent disclosure through previews, logs, or crash artifacts.

### Required Controls
- No preemptive rendering of sensitive history on entry.
- Export routes are auditable and bounded by documented disclosure classes.

### Verification Hook
- Coercion scenario matrix (screen-share, forced export, device seizure open/closed) with artifact capture.

## Pattern 5: User-Bound Key Derivation (No Master Decrypt)
### Problem
Centralized key paths enable institutional or operator mass disclosure.

### Pattern
- Derive record-decryption capability from user-bound secrets.
- Disallow backend-only decrypt endpoints.
- Treat recovery flows as key-path changes requiring explicit security review.

### Required Controls
- No hard-coded master secrets.
- No server-returned plaintext decryption key material.
- No recovery route introducing universal decrypt capability.

### Verification Hook
- Attempt decryption with backend-only secrets and privileged APIs; must fail.

## Pattern 6: Degraded-Mode Essential Budget
### Problem
Feature complexity breaks essential flows under weak devices/networks.

### Pattern
- Tag capabilities as `essential` or `non-essential`.
- Define degradation order where non-essential features disable first.
- Keep essential workflows within tested resource budgets.

### Required Controls
- Essential workflows complete under constrained network, memory, and CPU profiles.
- Degradation does not activate hidden telemetry or paywall prompts.

### Verification Hook
- Constrained-resource matrix with pass/fail thresholds on completion and integrity.

## Pattern 7: Metric Governance Guardrail
### Problem
Roadmap decisions drift toward engagement extraction.

### Pattern
- Maintain metric inventory classified as:
  - Outcome/Goal Completion
  - Engagement/Extraction
  - Mixed
- Require each essential workflow to map to at least one outcome metric with threshold.

### Required Controls
- Engagement metrics cannot be primary for essential workflow shipping decisions.
- Decision logs must cite outcome-linked evidence.

### Verification Hook
- Two-cycle roadmap decision trace + dark-metric probe.

## Release Checklist (Engineering Gate)
Before release, implementation SHOULD pass:
1. Offline parity tests for all essential workflows.
2. Reversibility transition tests for all declared reversible actions.
3. Data egress matrix conformance under all consent states.
4. Coercion scenario matrix disclosure-bound checks.
5. Key-path extraction tests proving absence of master decrypt.
6. Degraded-resource completion tests for essential workflows.
7. Metric governance review for outcome precedence.

## Audit Integration
- Normative spec: `/docs/spec/v1.0.html`
- Defensibility ledger: `/docs/spec/v1.0-must-justifications.html`
- Threat scenarios: `/THREAT_MODELS.md`
- Stage 3 semantic gate: `scripts/semantic-ledger-audit.ps1 -GateStage3`
- CI workflow: `.github/workflows/audit.yml`

## Change Control
Pattern updates should include:
- rationale,
- affected principles,
- verification method deltas,
- migration notes for existing implementations.
