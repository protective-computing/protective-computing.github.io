# Degraded Mode Requirements Checklist

Document Status: Draft
Target Norms: NORM-028, NORM-030, NORM-031, NORM-032, NORM-034
Implementation Status: Planning artifact only

Purpose: Translate the current Degraded Functionality blockers into a concrete implementation and verification checklist.

Normative basis:
- /DEGRADED_MODE_REMEDIATION_MATRIX.md
- /docs/spec/v1.0-must-justifications.html

## 1. Baseline Path Requirements

- [ ] Essential journaling flows remain available under constrained network, memory, CPU, and reduced-input conditions.
- [ ] A non-JS or JS-minimal baseline path exists for essential workflows where the current product claims degraded resilience.
- [ ] No sync-required or online-required modal blocks the essential path during degraded operation.

## 2. Low-Memory Requirements

- [ ] A target profile below 512MB RAM is defined and reproducible.
- [ ] Core create, read, update, and delete flows complete on that profile without crash or unusable stall.
- [ ] Memory-pressure handling does not discard in-progress essential work.

## 3. Keyboard And Reduced-Input Requirements

- [ ] Every essential interactive control is reachable without mouse or touch input.
- [ ] Date entry, chart access, modal actions, and export controls all have keyboard-equivalent paths.
- [ ] Focus order remains logical and visible across the critical path.

## 4. Feature-Shedding Requirements

- [ ] Non-essential features disable before essential workflows fail.
- [ ] The degradation order is documented and matches runtime behavior.
- [ ] Degraded mode does not activate hidden telemetry, unexpected media fetches, or paywall prompts.

## 5. Accessibility Requirements

- [ ] Critical workflows meet WCAG 2.1 AA color-contrast requirements.
- [ ] Screen readers can complete essential workflows without blocked controls.
- [ ] Labels, semantics, announcements, and ARIA usage are complete enough for end-to-end task completion.

## 6. Verification Requirements

- [ ] Constrained-resource regression runs show essential-path completion.
- [ ] Low-memory runs show stability below 512MB target profile.
- [ ] Keyboard-only walkthroughs show zero blocked essential controls.
- [ ] WCAG AA audit results pass for the essential path.

## 7. Annex Reconsideration Gate

Degraded Functionality should remain blocked until the checklist above is satisfied and the results are reflected consistently in:
- /docs/spec/v1.0-must-justifications.html
- /docs/reference-implementation/paintracker-mapping.html
- /AUDIT_ARTIFACT_DRAFT.md

## 8. Reviewer Note

This checklist is a planning artifact. Documentation alone is insufficient; the implementation and the evidence must both change.