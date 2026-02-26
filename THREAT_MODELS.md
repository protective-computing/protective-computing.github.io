# THREAT_MODELS.md

## Purpose
This document defines adversarial scenarios and protective constraints for systems implementing Protective Computing.
It is written for engineering, security, and audit workflows, not narrative framing.

## Scope
- Target systems: safety-critical, privacy-sensitive software operating under instability.
- Primary reference implementation: PainTracker mapping (`/docs/reference-implementation/paintracker-mapping.html`).
- This document is implementation-facing and complements the normative specification (`/docs/spec/v1.0.html`).

## Threat Classes
- State surveillance
- Institutional control
- Network tampering
- Device seizure
- Coercion / forced disclosure

## Security Objectives
1. Preserve essential utility under degraded and hostile conditions.
2. Minimize disclosure under coercion and surveillance pressure.
3. Prevent irreversible harm from routine or pressured user actions.
4. Keep critical workflows operable without institutional dependencies.

## System Boundaries
### In scope
- Client application behavior (UI, storage, sync, retention, export paths).
- Runtime network behavior and endpoint exposure.
- Key handling, recovery paths, and privileged API surfaces.

### Out of scope
- Physical device compromise beyond declared threat boundaries.
- Guaranteed forensic media destruction unless explicitly specified by implementation.
- Legal process outcomes outside technical control boundaries.

## Assumptions (Adversarial Baseline)
- Connectivity can be absent, censored, or monitored.
- Devices can be seized while app is open or closed.
- Users can be pressured to unlock, export, or reveal data.
- Institutions may delay or deny service at critical moments.
- Conventional engagement and growth incentives can conflict with user safety.

## Scenario Catalog

### Scenario 1: Institutional Delay & Network Denial
- Threat: Network access is restricted, unavailable, or hostile during critical workflow execution.
- Protective constraints: Local Authority, Degraded Functionality, Essential Utility.
- Required behavior:
  - Essential workflow completes offline.
  - Local writes commit without server handshake.
  - Sync queue reconciles later without data corruption.
- Verification anchor:
  - Run offline/intermittent/online matrix and compare to published parity rules.
  - Confirm no workflow labeled offline-capable requires server reachability.

### Scenario 2: Coerced Device Audit (App Open)
- Threat: User is forced to reveal data while app is unlocked and visible.
- Protective constraints: Coercion Resistance, Exposure Minimization, Essential Utility.
- Required behavior:
  - UI disclosure remains bounded to explicit user actions.
  - No hidden high-volume disclosure via “helpful” summary or export shortcuts.
  - Logs, previews, and caches do not leak additional sensitive content.
- Verification anchor:
  - Execute coercion scenario matrix; capture UI/video/log/export/storage artifacts.
  - Compare observed disclosure to documented coercion boundaries.

### Scenario 3: Device Seizure (App Closed)
- Threat: Device is seized after app closure; adversary attempts storage extraction.
- Protective constraints: Exposure Minimization, Coercion Resistance.
- Required behavior:
  - Sensitive records are not recoverable as plaintext from storage artifacts.
  - Decryption requires user-bound key material.
- Verification anchor:
  - Snapshot storage and perform strings/structured decode checks.
  - Attempt decryption with backend-only secrets; must fail.

### Scenario 4: Non-Consensual Data Egress
- Threat: Data transmitted to third parties without valid consent or documentation.
- Protective constraints: Exposure Minimization, Essential Utility.
- Required behavior:
  - Every outbound destination maps to declared processor and purpose.
  - Consent toggles affect transmission behavior deterministically.
  - No undocumented third-party endpoints receive user data.
- Verification anchor:
  - Build Data Egress Matrix from endpoint inventory + runtime capture.
  - Re-run workflows across opt-in/opt-out states; compare payload classes.

### Scenario 5: Transport Downgrade & Interception
- Threat: Adversary attempts downgrade or plaintext transport paths.
- Protective constraints: Exposure Minimization.
- Required behavior:
  - No HTTP equivalents for observed endpoints.
  - Downgrade attempts fail; weak suites rejected.
  - Sensitive fields are not visible in clear where app-layer encryption is claimed.
- Verification anchor:
  - TLS scanner + packet capture across all discovered endpoints.

### Scenario 6: Irreversible Harm by Design Drift
- Threat: Destructive or high-impact transitions are mislabeled or undocumented.
- Protective constraints: Reversibility.
- Required behavior:
  - Every state transition has explicit reversible/irreversible classification.
  - Reversible transitions restore prior state; irreversible actions are clearly disclosed.
- Verification anchor:
  - State-transition inventory with transition-by-transition restore/rollback tests.

### Scenario 7: Metric Capture Drift
- Threat: Product decisions optimize engagement over essential outcomes.
- Protective constraints: Essential Utility.
- Required behavior:
  - Essential workflows have outcome metrics with thresholds.
  - Engagement metrics are non-primary and cannot justify essential-path shipping.
- Verification anchor:
  - Metric inventory, dark-metric probe, and two-cycle roadmap decision trace.

### Scenario 8: Centralized Decryption Backdoor
- Threat: Operator or institution can decrypt user records without user secret.
- Protective constraints: Coercion Resistance, Exposure Minimization.
- Required behavior:
  - No universal master decrypt credential exists.
  - Recovery flows do not introduce backend-only decrypt capability.
- Verification anchor:
  - Key-path analysis, code/config search, privileged API extraction attempts.

## Residual Risk Disclosure
Implementations MUST publish explicit “resisted vs non-resisted” boundaries for coercion and seizure contexts.
Any unsupported scenario must be disclosed as a non-protected operating context.

## Audit Integration
- Normative source: `/docs/spec/v1.0.html`
- Defensibility ledger: `/docs/spec/v1.0-must-justifications.html`
- Semantic gate (Stage 3): `scripts/semantic-ledger-audit.ps1 -GateStage3`
- CI workflow: `.github/workflows/audit.yml`

## Change Control
Threat model updates SHOULD be versioned with rationale and linked to:
- New threat class inclusion,
- Boundary correction,
- Evidence from independent review or implementation audits.
