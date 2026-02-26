# COMPLIANCE_AUDIT_MATRIX.md

## Purpose
This matrix maps Protective Computing controls to common regulatory obligations and audit evidence.
It is an engineering/audit aid, not legal advice.

## Scope
- Jurisdictions/frameworks covered: GDPR, HIPAA, PIPEDA.
- Reference stack: Protective Computing specification, MUST justifications annex, threat models, implementation patterns, and CI artifacts.

## Interpretation Rule
Protective Computing often reduces compliance burden by design:
- data not collected,
- data retained minimally,
- data kept local/user-bound,
- no centralized decrypt capability.

Where data is never held by operator infrastructure, many controller/processor duties are reduced or re-scoped.

## Principle-to-Compliance Matrix

| Protective Principle | GDPR Alignment | HIPAA Alignment | PIPEDA Alignment | Primary Evidence |
| --- | --- | --- | --- | --- |
| Exposure Minimization | Art. 5(1)(c) Data minimization; Art. 5(1)(e) Storage limitation; Art. 25 Privacy by design/default | Minimum Necessary standard; Security Rule safeguards | Limiting Collection; Limiting Use/Disclosure/Retention; Safeguards | MUST ledger rows NORM-007, 010–014; egress matrix tests; retention tests |
| Local Authority | Data protection by design; resilience and availability controls where applicable | Availability/contingency expectations for essential workflows | Openness and individual control expectations in practical operation | NORM-018–021 verification artifacts; offline/online parity tests |
| Reversibility | Accuracy and rectification support through recoverability and bounded destructive actions | Integrity controls and recoverability expectations | Accuracy and individual challenge/correction practical support | NORM-001, 003–006 transition inventory and restore tests |
| Coercion Resistance | Risk reduction for unauthorized disclosure and disproportionate access | Access control and transmission/storage protection expectations | Safeguards and limiting disclosure under pressure contexts | NORM-022–027 coercion matrix, key-path tests, boundary disclosures |
| Degraded Functionality | Continuity of essential rights-related operations under unstable conditions | Availability and contingency posture under constrained operation | Appropriate safeguards and service continuity expectations | NORM-028–034 constrained-resource matrices |
| Essential Utility | Governance evidence that product incentives do not undermine protective obligations | Administrative governance alignment with safety-first operation | Accountability and policy coherence in user-protective operation | NORM-037–042 metric governance and subtraction drills |

## Obligation-to-Control Matrix

| Obligation Type | Protective Control Pattern | Example Verification |
| --- | --- | --- |
| Minimize collected data | Essential-only schema and per-field necessity mapping | Field-to-necessity ledger + runtime write inventory |
| Limit disclosure | Consent-linked egress matrix + no undocumented destinations | Capture traffic across consent states and diff |
| Protect at rest/in transit | User-bound key model + TLS posture controls | Storage plaintext scan + TLS downgrade rejection tests |
| Ensure bounded retention | Automatic expiry and irrecoverability within app access paths | Retention window test + post-expiry snapshots |
| Preserve user agency | Offline-capable essential workflows and local commit authority | Offline/intermittent/online execution matrix |
| Avoid hidden coercive paths | Coercion scenario matrix and export/log/caching disclosure bounds | S1–S6 scenario artifacts and boundary parity checks |

## Audit Evidence Pack (Recommended)
For any compliance review, provide:
1. Normative baseline: /docs/spec/v1.0.html
2. Defensibility ledger: /docs/spec/v1.0-must-justifications.html
3. Threat scenarios: /THREAT_MODELS.md
4. Implementation blueprints: /IMPLEMENTATION_PATTERNS.md
5. CI policy and outputs:
   - /.github/workflows/audit.yml
   - /scripts/semantic-ledger-audit.ps1
   - /scripts/audit-output/ artifacts

## Practical Audit Notes
- If architecture is local-first and operator cannot decrypt user records, document that boundary explicitly.
- Where obligations assume controller possession of personal data, show whether the operator actually possesses plaintext data in scope.
- Keep a release-by-release evidence trail for:
  - WEAK_VERIFICATION_COUNT,
  - transition inventory deltas,
  - egress matrix deltas,
  - key-path changes.

## Limitations
- This document does not replace counsel or formal legal interpretation.
- Regulatory applicability depends on deployment model, data classes, and organizational role.

## Change Control
Update this matrix when:
- new jurisdictions are targeted,
- principle controls materially change,
- threat boundaries or evidence methods are revised.
