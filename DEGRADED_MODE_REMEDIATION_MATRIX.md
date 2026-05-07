# Degraded Mode Remediation Matrix

Document Status: Draft
Target Norms: NORM-028, NORM-030, NORM-031, NORM-032, NORM-034
Implementation Status: Partial / Not Met

Purpose: Consolidate the current degraded-functionality gaps into a single remediation matrix that maps each blocker to the missing runtime behavior and required evidence.

Normative basis:
- /docs/spec/v1.0.html
- /docs/spec/v1.0-must-justifications.html
- /docs/reference-implementation/paintracker-mapping.html

## 1. Gap Matrix

| Norm | Current annex status | Current gap summary | Required remediation direction | Evidence needed before reconsideration |
| --- | --- | --- | --- | --- |
| NORM-028 | Partial | Constrained-resource continuity is incomplete because degraded behavior still depends on JS-heavy and accessibility-incomplete paths | Define and implement a baseline essential path that survives high latency, low memory, and reduced-input conditions | Constrained-resource matrix showing essential path completion without hidden telemetry or sync-required blocking |
| NORM-030 | Partial | Current low-memory claim is supported only by 1GB-class testing, not a sub-512MB target | Establish explicit low-memory target profile and prove core stability at that floor | Reproducible low-memory run logs and completion evidence on sub-512MB hardware or emulation |
| NORM-031 | Not Met | Keyboard navigation is incomplete for date picker, chart, and other non-text controls | Provide full keyboard parity for all essential controls and flows | Keyboard-only end-to-end evidence with blocked-control count at zero |
| NORM-032 | Partial | Degradation order is not explicit and JS dependency means failure mode is brittle instead of deterministic | Publish and implement feature-shedding policy where non-essential features degrade before the core path | Feature-priority degradation contract and constrained-resource verification runs |
| NORM-034 | Not Met | WCAG AA remains unmet due to chart contrast and incomplete screen-reader/date-picker support | Remediate contrast, semantics, focus, ARIA, and screen-reader support across essential flows | Passing WCAG AA audit report covering the critical path |

## 2. Current Honest Boundary

The reference implementation currently supports:
- responsive layouts,
- 2G core-path testing,
- no auto-media loading,
- and partial low-memory/mobile continuity.

It does not yet support:
- full non-JS baseline operation,
- full keyboard-only operation,
- or WCAG AA-complete essential workflows.

## 3. Audit Consequence

- This matrix explains why Degraded Functionality signoff remains blocked.
- It does not change the implementation state.
- The principle should remain unchecked until the missing runtime behavior is implemented and supported by reproducible evidence.