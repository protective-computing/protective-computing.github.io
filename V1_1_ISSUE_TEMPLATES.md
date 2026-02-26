# V1_1_ISSUE_TEMPLATES.md

Use these templates to open the first `v1.1` planning issues and keep scope tight (docs/process deltas only).

---

## Issue 1 — v1.1 Domain Extension Scaffold

**Title**
`v1.1: Domain extension scaffold (health / journalism / public-sector)`

**Labels**
`spec-gap`, `v1.1-planning`

**Body**
```markdown
## Objective
Define a repeatable extension scaffold for domain-specific guidance without changing the six core principles.

## Scope (in)
- Add extension structure template (problem context, threat deltas, implementation constraints, evidence requirements)
- Define required sections and naming conventions
- Specify compatibility rule with v1.0 normative baseline

## Scope (out)
- No new principles
- No normative keyword changes in v1.0
- No compliance-level rule changes

## Deliverables
- `/docs/extensions/README.md` (template contract)
- One worked example outline per domain (health, journalism, public-sector)
- Review checklist for extension quality

## Acceptance Criteria
- Extension scaffold exists and is versioned
- Compatibility with v1.0 is explicit and testable
- Independent reviewer can apply checklist to any extension draft

## Evidence
- PR link
- CI Stage 1/2/3 green
```

---

## Issue 2 — v1.1 Threat-Model Delta Process

**Title**
`v1.1: Threat-model delta process + evidence requirements`

**Labels**
`spec-gap`, `v1.1-planning`

**Body**
```markdown
## Objective
Formalize how threat-model changes are proposed, justified, reviewed, and accepted.

## Scope (in)
- Define threat-delta categories (new threat class, boundary correction, evidence correction)
- Define minimum evidence required per delta category
- Define reviewer sign-off requirements

## Scope (out)
- No immediate threat model expansion by default
- No speculative changes without reproducible evidence

## Deliverables
- Update `/THREAT_MODELS.md` with a "Delta Process" section
- Add reviewer evidence matrix (claim -> required artifact)
- Add change-log entry format for accepted deltas

## Acceptance Criteria
- Every threat-model change has category + evidence + sign-off
- Rejected deltas are tracked with rationale
- Process is executable by external reviewers

## Evidence
- PR link
- Example accepted/rejected delta records
- CI Stage 1/2/3 green
```

---

## Issue 3 — v1.1 Compliance Matrix Expansion

**Title**
`v1.1: Compliance matrix expansion (CCPA + SOC2 mapping notes)`

**Labels**
`spec-gap`, `v1.1-planning`

**Body**
```markdown
## Objective
Extend compliance mapping breadth without presenting legal guarantees.

## Scope (in)
- Add CCPA mapping notes to `/COMPLIANCE_AUDIT_MATRIX.md`
- Add SOC 2 control-family alignment notes (high-level engineering mapping)
- Keep explicit "not legal advice" and architecture-bound interpretation rules

## Scope (out)
- No jurisdiction-specific legal claims beyond engineering mapping
- No replacement of legal counsel

## Deliverables
- Updated matrix rows/sections for CCPA + SOC 2
- Additional evidence hooks per added framework
- Reviewer sanity checks for over-claim prevention

## Acceptance Criteria
- New mappings are evidence-linked and bounded
- Language avoids legal over-assertion
- Existing GDPR/HIPAA/PIPEDA mappings remain intact

## Evidence
- PR link
- Reviewer sign-off note
- CI Stage 1/2/3 green
```

---

## Milestone Template — v1.1 Planning

**Milestone title**
`v1.1 Planning`

**Description**
```markdown
Scope: documentation/process hardening only; no new principles and no v1.0 normative keyword changes.

Exit criteria:
1. Domain extension scaffold approved.
2. Threat-model delta process approved.
3. Compliance matrix expanded with bounded language and evidence hooks.
4. Stage 1/2/3 CI remains green on all merged PRs.
```

**Due date (suggested)**
`+30 days from creation`

---

## Branch Protection Checklist (main)

Configure in GitHub Settings > Branches > `main`:

- Require pull request before merging
- Require status checks to pass before merging:
  - `metadata-audit / Run metadata audit`
  - `metadata-audit / Run semantic ledger audit (Stage 2)`
  - `metadata-audit / Run semantic ledger audit (Stage 3)`
- Require branches to be up to date before merging
- Restrict force pushes
- Restrict deletion

Optional hardening:
- Require at least 1 approving review
- Dismiss stale approvals when new commits are pushed

---

## Release Note Stub (v1.1 planning kickoff)

```markdown
## v1.1 Planning Kickoff

This cycle is limited to process/documentation hardening:
- Domain extension scaffold
- Threat-model delta governance
- Compliance matrix expansion (CCPA + SOC2 notes)

No changes to v1.0 normative principle set.
All merges continue to require Stage 1/2/3 green CI.
```
