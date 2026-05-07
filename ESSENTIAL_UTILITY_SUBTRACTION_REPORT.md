# Essential Utility Subtraction Report

Version: 2026-03-18

Status: Passing subtraction drill report.

Scope: PainTracker reference implementation essential-utility review.

Purpose: Record the versioned subtraction drill evidence required to support NORM-035 and NORM-037.

Normative basis:
- /docs/spec/v1.0.html
- /docs/spec/v1.0-must-justifications.html
- /docs/principles/essential-utility.html

## Verification Summary

Overall result: Pass

Reason:
- Removing the highest-value non-essential features does not break the essential local journaling path, clinician-summary export, or privacy-critical controls.

## Essential Workflows Rechecked

The following workflows were treated as non-negotiable during each subtraction run:
- create a local entry,
- review existing entries,
- edit and delete entries,
- restore within the recovery window,
- export a clinician-ready summary,
- and access privacy-critical settings.

## Subtraction Runs

| Run | Removed or disabled feature | Result | Evidence summary |
| --- | --- | --- | --- |
| ESS-SUB-01 | Optional encrypted backup | Pass | Local journaling, history review, deletion, restore behavior, and clinician-summary export remained fully available on the active device |
| ESS-SUB-02 | Trend chart visualization | Pass | Users still identified patterns through the journal history list and exported summaries; no essential workflow broke |
| ESS-SUB-03 | Multi-device sync | Pass | Single-device essential workflows remained intact; only cross-device propagation was lost |

## Findings

- Optional encrypted backup is a resilience feature, not a prerequisite for essential local use.
- Trend charts improve convenience and interpretation speed, but are not required for the essential record-and-review path.
- Multi-device sync improves continuity across devices, but does not define the minimum protective utility boundary.

## Audit Consequence

- The reference implementation now has a published subtraction-test artifact.
- Combined with /FEATURE_JUSTIFICATION_MATRIX.md, this closes the prior documentation gap called out in the annex for NORM-035 and NORM-037.
- Essential Utility signoff can be treated as complete if all other Essential Utility rows remain Met.