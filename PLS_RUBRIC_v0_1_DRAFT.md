# PLS_RUBRIC_v0_1_DRAFT.md

## Protective Legitimacy Score (PLS) — Operational Rubric v1.0 (Draft)

## Purpose
Convert principle conformance into an auditable, reproducible score for implementation review.

## Scoring Model
- Score range: `0–100`
- Principle scores: `0–4` each
- Weighted composite with hard fail guards

## Principle Weights
- Reversibility: 16
- Exposure Minimization: 18
- Local Authority: 18
- Coercion Resistance: 18
- Degraded Functionality: 15
- Essential Utility: 15

Total: 100

## Per-Principle Level Mapping
- `0` = Not implemented / contradicts requirement
- `1` = Basic claim, weak or incomplete verification
- `2` = Implemented with partial evidence
- `3` = Verified by reproducible adversarial tests
- `4` = Verified + independent review evidence

## Hard Fail Guards
Any of the following sets overall disposition to `Fail` regardless of weighted score:
1. Stage 3 gate failure (`WEAK_VERIFICATION_COUNT > 0`)
2. Evidence of master decrypt/backdoor capability
3. Essential workflow paywall or lockout in free/critical path
4. Missing threat-boundary disclosure for coercion contexts

## Evidence Inputs (Minimum)
- Stage 1/2/3 CI outputs
- MUST justifications ledger rows and statuses
- Threat scenario artifacts (coercion, offline, egress, key-path)
- Implementation verification logs (pass/fail criteria)

## Computation
For each principle:

`principle_points = (level / 4) * weight`

`PLS = sum(principle_points)`

## Disposition Bands
- `85–100`: Strong legitimacy (operationally reliable)
- `70–84`: Conditional legitimacy (targeted remediation required)
- `50–69`: Weak legitimacy (substantial gaps)
- `<50`: Non-legitimate under Protective standard

## Reporting Format
A compliant report should include:
1. Commit/version reviewed
2. Principle levels (0–4) + rationale
3. Weighted total
4. Hard fail guard checks
5. Required remediation and re-test conditions

## v1.0 Draft Constraints
- Draft is process guidance; not yet normative spec text.
- Any promotion to normative status requires independent-review feedback cycle.
