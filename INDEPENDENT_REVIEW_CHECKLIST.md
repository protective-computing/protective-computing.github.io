# INDEPENDENT_REVIEW_CHECKLIST.md

## Purpose
Standardized checklist for third-party reviewers to evaluate Protective Computing claims consistently.

## Pre-Flight
- [ ] Confirm target commit hash and branch.
- [ ] Confirm scope (spec version, implementation under review).
- [ ] Confirm reviewer is using current docs:
  - `/docs/spec/v1.0.html`
  - `/docs/spec/v1.0-must-justifications.html`
  - `/THREAT_MODELS.md`
  - `/IMPLEMENTATION_PATTERNS.md`

## Gate Verification
- [ ] Run Stage 1 metadata audit.
- [ ] Run Stage 2 semantic gate.
- [ ] Run Stage 3 semantic gate.
- [ ] Verify `WEAK_VERIFICATION_COUNT=0` in output.

## Normative Integrity
- [ ] Spot-check MUST/MUST NOT rows in annex for:
  - threat alignment present
  - failure-if-downgraded present
  - executable verification method present
  - status vocabulary valid (`Met`, `Partial`, `Not Met`, `N/A`)
- [ ] Confirm `Partial` rows include explicit `To reach Met:` path.

## Adversarial Scenario Checks
- [ ] Validate at least one offline/network denial scenario.
- [ ] Validate at least one coercion/forced disclosure scenario.
- [ ] Validate at least one data egress/consent scenario.
- [ ] Validate at least one key-path/backdoor absence scenario.

## Evidence Quality Checks
- [ ] Verification methods include reproducible Environment/Action/Pass-Fail structure.
- [ ] Evidence claims do not exceed documented threat boundaries.
- [ ] No reliance on privileged assumptions that violate principle scope.

## Compliance Mapping Sanity
- [ ] Review `/COMPLIANCE_AUDIT_MATRIX.md` for alignment rationale.
- [ ] Confirm mappings are presented as engineering guidance, not legal guarantees.

## Findings Output Template
Use this structure:
1. Scope reviewed
2. Gates result (Stage 1/2/3)
3. Passed controls
4. Failed controls
5. Evidence quality issues
6. Required remediation
7. Final disposition (Accept / Conditional / Reject)

## Escalation Rules
- Any Stage 3 failure (`WEAK_VERIFICATION_COUNT > 0`) => Reject until fixed.
- Any mismatch between documented boundary and observed behavior => Conditional/Reject based on severity.
- Any unverifiable coercion or key-management claim => Reject until evidence is reproducible.
