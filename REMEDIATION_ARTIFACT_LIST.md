# Remediation Artifact List

Version: 2026-03-18

Purpose: Define the concrete publishable artifacts still needed to close currently blocked audit signoffs for the PainTracker reference implementation.

Scope:
- Exposure Minimization
- Local Authority
- Coercion Resistance
- Degraded Functionality

Status rule:
- This file is a remediation planning artifact, not a compliance claim.
- A listed artifact only closes a blocker if it is published, versioned, and consistent with the normative annex in /docs/spec/v1.0-must-justifications.html.

## 1. Exposure Minimization

Current blocker summary:
- Previously blocked by indefinite local journal retention and undocumented backup-service metadata retention.

Required remediation artifacts:

| Artifact | Purpose | Closes which gap | Minimum content |
| --- | --- | --- | --- |
| Local retention default specification | Define automatic expiry defaults for local journal data | NORM-007, NORM-013 | Default retention windows by field class, override policy, user notice rules, expiry semantics, recovery behavior after expiry |
| Backup-service metadata retention policy | Bound operator-visible metadata exposure | NORM-007, NORM-013 | Explicit retention windows for IP addresses, connection timestamps, sync activity, deletion triggers, log minimization rules |
| Retention enforcement verification report | Prove implementation matches policy | NORM-007, NORM-013 | Test runs for expiry, screenshots or logs before/after expiry, residue checks, export/search behavior after expiry |

Published status:
- /LOCAL_RETENTION_DEFAULT_SPEC.md now documents implemented automatic local-expiry behavior.
- /BACKUP_SERVICE_METADATA_RETENTION_POLICY.md now documents implemented bounded retention for operator-visible metadata.
- /RETENTION_ENFORCEMENT_VERIFICATION_REPORT.md now records a passing verification result for retention enforcement.

Exit condition for signoff:
- Satisfied: local and metadata retention are now explicit, automatic where required, and reflected as Met in the annex.

## 2. Local Authority

Current blocker summary:
- NORM-015 remains Partial because the repo does not yet publish a versioned no-server operating profile for all essential functions.
- NORM-021 remains Partial because the repo does not yet publish a formal offline/intermittent/online parity and sync-behavior specification.

Required remediation artifacts:

| Artifact | Purpose | Closes which gap | Minimum content |
| --- | --- | --- | --- |
| No-server operating profile | Define the exact essential feature set available without server reachability | NORM-015 | Essential workflows, server-dependent workflows, account deletion behavior, local-only operating assumptions, explicit non-essential server couplings |
| Offline/online parity matrix | Publish formal feature parity across connectivity states | NORM-021 | Offline, intermittent, online columns; feature availability; exposure differences; degradation notes; recovery expectations |
| Sync behavior specification | Publish a single authoritative sync contract | NORM-021 | Queue behavior, sync triggers, conflict policy, reconciliation timing, documented exposure on reconnect, failure handling |

Implementation note:
- The current repo describes sync both as last-write-wins with timestamps and as CRDT-style vector-clock replication. That conflict must be resolved before Local Authority signoff can be completed.

Exit condition for signoff:
- The repo publishes a consistent no-server profile and parity/sync specification, and the annex can honestly move NORM-015 and NORM-021 to Met.

## 3. Coercion Resistance

Current blocker summary:
- NORM-022 is Not Met because the reference implementation lacks plausible deniability and a coercion-safe operating mode for forced-unlock or compelled-disclosure contexts.

Required remediation artifacts:

| Artifact | Purpose | Closes which gap | Minimum content |
| --- | --- | --- | --- |
| Coercion boundary matrix | Publish explicit resisted vs non-resisted coercion scenarios | NORM-022 | Forced unlock, compelled export, device open/closed seizure, operator demand, metadata disclosure paths, bounded disclosures |
| Deniability / coercion-safe mode design brief | Specify the missing product control needed for active-coercion contexts | NORM-022 | Candidate deniability model, user flows, security assumptions, failure modes, operational risks, rollout constraints |
| Coercion scenario evidence packet | Verify observed disclosure against the documented boundary | NORM-022, NORM-027 | Screen recordings, export artifacts, cache/log inspection, scenario matrix results, disclosure-class inventory |

Published status:
- /COERCION_BOUNDARY_MATRIX.md now publishes the current resisted-versus-non-resisted coercion boundary.
- /COERCION_SAFE_MODE_DESIGN_BRIEF.md now defines the missing coercion-safe control as an implementation target.
- /COERCION_SCENARIO_EVIDENCE_PACKET.md now records the current-state scenario results, including the failing forced-unlock and compelled-export runs.
- /DURESS_MODE_REQUIREMENTS_CHECKLIST.md now converts the coercion boundary threshold into an implementation checklist for future NORM-022 reconsideration.
- /DURESS_MODE_IMPLEMENTATION_SPEC.md now defines the required state model, failure handling, and verification targets for a future duress branch.

Important constraint:
- Documentation alone does not close this blocker unless the implementation actually gains the promised coercion-safe control. A design brief is necessary for planning, but insufficient for signoff by itself.

Exit condition for signoff:
- The implementation gains a defensible coercion-safe control, publishes its boundary clearly, and the annex can honestly move NORM-022 out of Not Met.

## 4. Degraded Functionality

Current blocker summary:
- NORM-028 and NORM-032 remain Partial because degraded-mode continuity is not yet fully defined as an essential-first baseline.
- NORM-030 remains Partial because current evidence does not prove operation below the 512MB RAM floor.
- NORM-031 remains Not Met because keyboard parity is incomplete.
- NORM-034 remains Not Met because WCAG AA support is incomplete for the critical path.

Required remediation artifacts:

| Artifact | Purpose | Closes which gap | Minimum content |
| --- | --- | --- | --- |
| Degraded mode remediation matrix | Consolidate remaining degraded-mode blockers | NORM-028, NORM-030, NORM-031, NORM-032, NORM-034 | Current gap summary, remediation direction, evidence threshold |
| Degraded mode requirements checklist | Convert blockers into implementation and verification requirements | NORM-028, NORM-030, NORM-031, NORM-032, NORM-034 | Baseline path, low-memory, keyboard, feature-shedding, accessibility, verification gates |
| Degraded mode implementation spec | Define target runtime behavior and degradation order | NORM-028, NORM-030, NORM-031, NORM-032, NORM-034 | Essential-first degradation order, fallback rules, verification model |

Published status:
- /DEGRADED_MODE_REMEDIATION_MATRIX.md now consolidates the current degraded-functionality blockers.
- /DEGRADED_MODE_REQUIREMENTS_CHECKLIST.md now converts those blockers into an implementation and verification checklist.
- /DEGRADED_MODE_IMPLEMENTATION_SPEC.md now defines the target degraded-runtime behavior required before annex reconsideration.

Important constraint:
- Planning artifacts do not close Degraded Functionality on their own. The runtime behavior and accessibility evidence must change before the annex can move the blocked rows.

Exit condition for signoff:
- The implementation ships a defensible essential-first degraded baseline, keyboard parity, sub-512MB evidence, and passing WCAG AA coverage for the critical path, and the annex can honestly move the blocked rows to Met.

## Reviewer Guidance

- Treat this file as the bridge between honest audit blockers and concrete next artifacts.
- Do not mark any blocked principle complete solely because a planning artifact exists.
- When an artifact listed here is published, update:
  - /docs/spec/v1.0-must-justifications.html
  - /AUDIT_ARTIFACT_DRAFT.md
  - /AUDIT_EVIDENCE.md
  - /README.md
