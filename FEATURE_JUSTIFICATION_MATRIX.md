# Feature Justification Matrix

Version: 2026-03-18

Scope: PainTracker reference implementation documented in /docs/reference-implementation/paintracker-mapping.html.

Purpose: Publish the versioned feature-to-need mapping required for Essential Utility review, aligned to NORM-037 and supporting NORM-035.

Normative basis:
- /docs/spec/v1.0.html
- /docs/spec/v1.0-must-justifications.html
- /docs/principles/essential-utility.html

## Essential Workflow Basis

Canonical essential workflows for the reference implementation:
- create a local pain entry,
- review prior entries,
- edit or delete entries,
- restore within the documented recovery window,
- export a clinician-ready summary,
- and manage privacy-critical settings such as retention and backup participation.

## Feature Inventory

| Feature or behavior | Type | Linked essential workflow or protective requirement | Why it exists | Removal impact | Classification |
| --- | --- | --- | --- | --- | --- |
| New entry form | User-facing | Create a local pain entry | Captures symptom severity, location, treatment, and notes for the core journaling task | Core utility fails without it | Essential |
| Journal history list | User-facing | Review prior entries | Lets users identify patterns and review prior records locally | Core review workflow fails without it | Essential |
| Entry editing | User-facing | Edit existing entries | Corrects mistakes and preserves record integrity | Data integrity degrades without it | Essential |
| Entry deletion with recovery window | User-facing | Delete entries and restore within boundary | Allows user control while preserving reversibility protections | Privacy and reversibility guarantees degrade without it | Essential |
| Clinician-ready summary export | User-facing | Export a clinician-ready summary | Supports medical communication from the local journal | Medical communication workflow degrades without it | Essential |
| Retention controls | User-facing | Manage privacy-critical settings | Lets users apply or extend documented retention behavior | Privacy posture becomes opaque without it | Essential protective control |
| Optional encrypted backup | User-facing plus background | Protective resilience requirement; not essential to single-device use | Supports restore and multi-device continuity without being required for local journaling | Essential local workflows continue if removed | Non-essential resilience feature |
| Multi-device sync | Background plus user-visible | Convenience and resilience; not required for single-device local operation | Propagates already-authoritative local changes across devices | Essential local workflows continue if removed | Non-essential resilience feature |
| Trend chart visualization | User-facing | Pattern identification support | Summarizes history visually, but underlying history remains available without it | Pattern review remains possible through journal history | Non-essential utility enhancer |
| Date picker widget | User-facing | New entry form support | Improves date entry convenience | Manual date entry remains possible if replaced by plain input | Non-essential convenience feature |
| Outcome metric collection for goal completion | Background governance | NORM-040 protective requirement | Measures whether users complete survival-critical tasks without using engagement metrics as the primary goal | Governance guardrail weakens without it | Essential governance feature |
| Notifications, streaks, leaderboards, upsell prompts | Intentionally absent | None | Excluded because they would add manipulation or extraction pressure | No essential workflow depends on them | Forbidden / intentionally not shipped |

## Inventory Conclusions

- Every shipped feature maps either to an essential workflow, a protective requirement, or a bounded non-essential resilience/convenience role.
- The only clearly non-essential shipped features are optional encrypted backup, multi-device sync, trend-chart visualization, and convenience date-entry affordances.
- No shipped feature is justified solely by engagement, retention, or monetization.

## Change Control

Update this matrix whenever:
- a new user-facing feature is shipped,
- a background behavior changes user risk,
- or an existing feature changes from optional to essential or vice versa.