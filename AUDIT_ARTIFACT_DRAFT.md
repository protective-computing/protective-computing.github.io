# Audit artifact (draft)

Source: https://protective-computing.github.io/docs/audit-checklist.html

### Six principles summary

| Requirement | How to test |
| --- | --- |
| **Reversibility**
User actions and system changes must be recoverable within documented boundaries; failures must not become permanent harm. | Run destructive-action regression, recovery-window disclosure checks, crash-recovery tests, and adversarial deletion attempts. Verify undo paths, delay windows, and documented irreversibility boundaries. |
| **Exposure Minimization**
Collect only essential data, defend it cryptographically, and enforce automatic retention limits. | Audit field justification, storage encryption, TLS posture, retention expiry, logs, and data egress. Confirm every field has a purpose and every disclosure path is bounded. |
| **Local Authority**
Essential work must remain possible without continuous server reachability or live re-authentication. | Execute full essential workflows in airplane mode, under expired tokens, and across interrupted sync. Validate local cache integrity, non-blocking sync, and published offline/online parity. |
| **Coercion Resistance**
Users must retain confidentiality and integrity under physical, legal, and administrative pressure. | Perform server-side decrypt-failure checks, KDF and passphrase validation, threat-model review, forced-disclosure tabletop exercises, and backdoor hunts. |
| **Degraded Functionality**
Core utility must survive constrained bandwidth, power, compute, and input conditions. | Throttle to 2G, constrain memory and CPU, audit keyboard-only flows, test non-essential feature shedding, confirm no media autoload, and run WCAG AA checks. |
| **Essential Utility**
Features must serve survival and autonomy, not engagement, extraction, or coercive monetization. | Run feature-justification review, subtraction drills, dark-pattern probes, metric audits, and paywall checks. Confirm essential workflows stay free of manipulative friction. |

---

### 1) Reversibility

**Target user risk:** Accidental deletion, coerced action, panic clicks, crash-driven loss, or misleading flows turn routine mistakes into irreversible harm.

**Minimum system guarantees:** Destructive actions can be undone, recovery windows are visible, permanent deletion is delayed, and the system clearly documents what cannot be recovered.

**Measurable acceptance criteria**

- 100% of destructive actions expose an undo or recovery path, or explicitly declare irreversibility.
- Permanent deletion always requires explicit confirmation and an enforced delay of at least 7 days.
- Crash or restart does not silently discard in-progress essential work.

**Candidate tests (5)**

- `REV-A1` (Automated) Destructive action undo regression
    - Preconditions: Seeded account or fixture data; destructive flows available; online and offline test modes.
    - Steps: Run integration tests for delete, modify, and publish actions. Trigger action, invoke undo, then confirm original state is restored within the documented recovery window.
    - Expected outcome: Every destructive action exposes a working undo path or restore flow; no state corruption or hidden residual damage remains.
    - Evidence: CI logs, before/after snapshots, restored record IDs, recovery-window timestamps.
    - MUST: NORM-001, NORM-003
- `REV-A2` (Automated) Crash and restart recovery
    - Preconditions: Draft/edit flow available; app restart or browser reload scriptable; optional offline mode.
    - Steps: Begin editing an essential record, interrupt with crash/reload/power-loss simulation, relaunch, then check draft presence and recovery affordance.
    - Expected outcome: Essential work survives interruption or is recoverable through an explicit restoration flow; no silent data discard occurs.
    - Evidence: Crash logs, local storage snapshot, relaunch video, recovered draft state.
    - MUST: NORM-001
- `REV-M1` (Manual) Recovery-window disclosure walkthrough
    - Preconditions: Device build with production UI; destructive actions reachable from normal navigation.
    - Steps: Walk every delete/archive/reset path. Record the exact warning text, recovery window wording, and whether the time boundary is visible before execution.
    - Expected outcome: Every destructive flow clearly shows the recovery window duration and the consequence of expiry before the action completes.
    - Evidence: Screenshots of warnings, screen recording of the flow, UI text inventory.
    - MUST: NORM-004, NORM-005
- `REV-M2` (Manual) Reversibility boundary review
    - Preconditions: Published docs or internal transition inventory available; access to all user-triggerable state transitions.
    - Steps: Enumerate create, edit, delete, export, sync, reset, migration, and expiry actions. Mark each as reversible or irreversible, then verify runtime matches the label.
    - Expected outcome: No state transition lacks a reversibility label, and no transition behaves differently from its published classification.
    - Evidence: Action inventory, screenshots, before/after state captures, documentation diff.
    - MUST: NORM-006
- `REV-U1` (Abuse) Coerced rapid-delete attempt
    - Preconditions: Attacker has brief unlocked-device access; user regains access within recovery window.
    - Steps: Attempt immediate deletion of sensitive records, force close the app, then return to the user account and attempt restoration from local UI or documented recovery path.
    - Expected outcome: Deletion cannot become instantly irreversible; confirmation and delay controls leave the user a realistic recovery path.
    - Evidence: Screen recording of attack and restore attempt, deletion timestamps, restore confirmation.
    - MUST: NORM-005, NORM-001

### 2) Exposure Minimization

**Target user risk:** Over-collection, plaintext storage, long retention, and undisclosed sharing make breach, subpoena, coercion, and analytics leakage materially worse.

**Minimum system guarantees:** Every field is justified, sensitive values are encrypted, transport is hardened, retention is explicit and automatic, and no third-party disclosure occurs without informed opt-in consent.

**Measurable acceptance criteria**

- Every persisted field maps to a documented essential use case.
- No sensitive data appears in plaintext at rest, in logs, or on the wire.
- Retention-expired records become inaccessible and leave no application-readable residue.

**Candidate tests (5)**

- `EXP-A1` (Automated) Field-justification ledger gate
    - Preconditions: Schema definition and versioned field inventory available in repo.
    - Steps: Diff the current schema against the field-justification ledger. Fail CI if any new or existing stored field lacks necessity, sensitivity class, and retention bound.
    - Expected outcome: No persisted field exists without explicit justification and retention metadata.
    - Evidence: CI artifact showing schema diff, justification ledger, failing/passing rows.
    - MUST: NORM-007, NORM-010
- `EXP-A2` (Automated) At-rest encryption and log scan
    - Preconditions: Access to local storage, database export, and application logs in a test profile containing sensitive data.
    - Steps: Seed sensitive records, export local storage and logs, then search for plaintext values and keys. Validate encryption algorithm and key-handling metadata.
    - Expected outcome: No sensitive values are readable without decryption material; logs do not contain payload data or secrets.
    - Evidence: Storage export, grep output, encryption config summary, redacted logs.
    - MUST: NORM-007, NORM-011
- `EXP-A3` (Automated) TLS and outbound egress audit
    - Preconditions: Network inspector or proxy capture; endpoint inventory; consent toggles if present.
    - Steps: Run essential workflows, capture outbound requests, scan endpoints for TLS posture, and compare observed egress against documented processor list and consent state.
    - Expected outcome: All traffic is TLS-protected, no plaintext endpoint exists, and no data leaves the system outside declared and consented channels.
    - Evidence: Packet capture, TLS scan reports, endpoint list, consent-state matrix.
    - MUST: NORM-012, NORM-014
- `EXP-M1` (Manual) Retention expiry walkthrough
    - Preconditions: Test configuration with short retention window; ability to inspect data before and after expiry.
    - Steps: Create records, wait past the configured retention boundary, then verify UI access, search, export, and recovery paths after expiry.
    - Expected outcome: Expired data no longer appears in the UI, exports, or app-level searches, and the retention behavior matches published policy.
    - Evidence: Screenshots before and after expiry, retention settings, export attempt results.
    - MUST: NORM-013
- `EXP-U1` (Abuse) Compromised-device extraction attempt
    - Preconditions: Attacker has filesystem access to a seized device or backup image.
    - Steps: Attempt to recover records through local DB dumps, crash logs, cached previews, and third-party SDK artifacts without valid user credentials.
    - Expected outcome: Only ciphertext or bounded metadata is accessible; no plaintext payload leakage appears through side channels.
    - Evidence: Filesystem snapshot, extracted files, plaintext scan output, screenshots of failed recovery.
    - MUST: NORM-007, NORM-011, NORM-013, NORM-014

### 3) Local Authority

**Target user risk:** Users are locked out by outages, throttling, censorship, captive portals, or server-side policy decisions exactly when they most need the system.

**Minimum system guarantees:** Essential workflows run offline, essential data remains cached locally, sync is asynchronous and non-blocking, offline access does not require live auth, and parity/sync behavior is documented.

**Measurable acceptance criteria**

- Essential CRUD or equivalent critical tasks complete in airplane mode with zero blocking network dependency.
- Expired or unavailable server tokens do not prevent offline access to cached essential data.
- Observed sync and parity behavior matches the published offline/online matrix.

**Candidate tests (6)**

- `LOC-A1` (Automated) Airplane-mode essential workflow suite
    - Preconditions: Seeded local dataset; network disabled at OS level; network inspector enabled.
    - Steps: Execute essential create, read, update, and delete flows in airplane mode, including app restart between operations.
    - Expected outcome: All essential workflows complete without server reachability and without emitting outbound traffic or blocking prompts.
    - Evidence: CI or device logs, network trace showing zero outbound requests, state snapshots after restart.
    - MUST: NORM-015, NORM-017
- `LOC-A2` (Automated) Local cache persistence and reload test
    - Preconditions: Previously synced records on device; ability to force reload while offline.
    - Steps: Disconnect network, edit a record, reload the app, then inspect whether cached records and recent local edits are still accessible.
    - Expected outcome: The user retains a readable, internally consistent local copy with no silent rollback.
    - Evidence: Storage snapshot, screenshots before/after reload, offline render proof.
    - MUST: NORM-018
- `LOC-A3` (Automated) Asynchronous sync under packet loss
    - Preconditions: Sync-enabled build; simulated latency >= 2000ms and packet loss >= 30%.
    - Steps: Perform several writes while the network is unstable, then reconnect and inspect queue replay, conflict handling, and UI responsiveness.
    - Expected outcome: Writes persist locally immediately, UI remains usable, and reconciliation occurs without duplication, corruption, or lockup.
    - Evidence: Queue logs, network trace, conflict-resolution output, before/after record counts.
    - MUST: NORM-019
- `LOC-M1` (Manual) Offline access without live re-authentication
    - Preconditions: Cached data on device; server tokens expired or revoked; network disabled.
    - Steps: Close the app, expire credentials, relaunch offline, and attempt access to essential cached records.
    - Expected outcome: Essential cached content remains accessible without requiring live auth or support intervention.
    - Evidence: Video walkthrough, expired-token proof, screenshots of accessible cached content.
    - MUST: NORM-020
- `LOC-M2` (Manual) Parity and sync documentation review
    - Preconditions: Published offline/online feature matrix and sync documentation available.
    - Steps: Compare the published parity matrix against observed behavior across offline, intermittent, and online states, including conflict resolution.
    - Expected outcome: Feature parity and sync semantics are accurately documented, with no undocumented exposure or behavior differences.
    - Evidence: Documentation snapshot, comparison notes, screenshots of each mode.
    - MUST: NORM-021
- `LOC-U1` (Abuse) Account lockout or censorship scenario
    - Preconditions: User account is throttled, region-blocked, or identity provider is unavailable; device remains in user possession.
    - Steps: Simulate server-side lockout, then attempt essential local operations and data access entirely offline.
    - Expected outcome: Server-side denial does not remove the user's local authority over essential data and workflows.
    - Evidence: Lockout logs, offline screenshots, attempted server calls, local export artifacts.
    - MUST: NORM-015, NORM-017, NORM-020

### 4) Coercion Resistance

**Target user risk:** Forced unlock, legal compulsion, device seizure, insider access, or master-key architectures convert a protective system into a disclosure mechanism.

**Minimum system guarantees:** Server operators cannot decrypt user content, user-held secrets remain required, passphrases are strong, KDFs are slow, no administrative backdoor exists, and the threat model says what the system cannot protect.

**Measurable acceptance criteria**

- Server-side access alone cannot produce plaintext.
- Credential policy enforces high-entropy passphrases and modern KDFs.
- Observed coercion boundaries match documented claims, with no hidden disclosure channels.

**Candidate tests (6)**

- `COE-A1` (Automated) Server-side decrypt failure
    - Preconditions: Encrypted data on server or backup; admin credentials only; no user secret material.
    - Steps: Attempt to decrypt or export readable user content from server-side storage using operator privileges alone.
    - Expected outcome: Only ciphertext or bounded metadata is obtainable; plaintext remains inaccessible without user-held secrets.
    - Evidence: Server export artifact, failed decrypt logs, ciphertext samples, admin-only access transcript.
    - MUST: NORM-022, NORM-023
- `COE-A2` (Automated) Passphrase policy and cracking resistance
    - Preconditions: Credential policy visible in code or runtime; test ciphertext or backup available.
    - Steps: Validate passphrase rules, generate policy-minimum examples, and run controlled cracking attempts against encrypted fixtures.
    - Expected outcome: Weak passphrases are rejected or flagged; minimum accepted passphrases remain infeasible to recover in controlled attack windows.
    - Evidence: Policy screenshots, cracking benchmark output, accepted/rejected credential logs.
    - MUST: NORM-024
- `COE-A3` (Automated) KDF and backdoor regression
    - Preconditions: Source or binary inspection access; key derivation configuration; recovery flows accessible.
    - Steps: Search for hard-coded keys, master secrets, legacy KDFs, privileged decryption endpoints, and recovery flows that bypass user-bound secrets.
    - Expected outcome: No administrative backdoor or master key exists; only approved slow KDFs are allowed in build or runtime configuration.
    - Evidence: Static scan report, config dump, API inventory, failed privileged decryption attempts.
    - MUST: NORM-025, NORM-026
- `COE-M1` (Manual) Threat-model disclosure review
    - Preconditions: Public threat model, privacy claims, or product security documentation available.
    - Steps: Read the declared coercion boundary, then compare it against storage, export, cache, and support behavior observed in the product.
    - Expected outcome: The product does not over-claim. Documentation clearly states what an attacker can and cannot extract.
    - Evidence: Threat-model excerpt, screenshots of claims, observed behavior notes.
    - MUST: NORM-027
- `COE-U1` (Abuse) Forced-unlock tabletop
    - Preconditions: Attacker gains temporary physical control of an unlocked device; user cannot refuse interaction.
    - Steps: Walk through shoulder-surf, forced export, and forced navigation to sensitive history while capturing what the UI, exports, and cached views reveal.
    - Expected outcome: The system's protective boundary is explicit, bounded, and consistent with documented coercion claims; no surprise disclosure channels appear.
    - Evidence: Screen recording, exported files, cached preview inspection, disclosure matrix.
    - MUST: NORM-022, NORM-027
- `COE-U2` (Abuse) Compelled operator disclosure attempt
    - Preconditions: Operator has DB access, admin console access, and legal demand scenario assumptions.
    - Steps: Attempt to satisfy a disclosure request using operator access only, including backups, support tooling, and admin exports.
    - Expected outcome: Operator can provide only the limited data classes explicitly allowed by architecture, never hidden plaintext or universal decrypt capability.
    - Evidence: Support export screenshots, admin console output, backup sample, disclosure classification notes.
    - MUST: NORM-023, NORM-026

### 5) Degraded Functionality

**Target user risk:** Critical workflows fail on weak links, old devices, keyboard-only input, screen readers, or battery-constrained conditions, effectively excluding vulnerable users.

**Minimum system guarantees:** The baseline path works on 2G, low-memory devices, and keyboard-only or assistive contexts; non-essential features degrade first; media never autoloads.

**Measurable acceptance criteria**

- Initial HTML payload for the baseline path remains under the declared 2G budget.
- Core tasks remain operable under constrained CPU, memory, and input conditions.
- Critical workflows pass keyboard and WCAG 2.1 AA checks.

**Candidate tests (7)**

- `DEG-A1` (Automated) Constrained-resource regression suite
    - Preconditions: Browser/device emulation with CPU throttling, latency, and reduced-memory profiles.
    - Steps: Run the essential workflow suite under constrained network, CPU, and memory settings, confirming non-critical features degrade first.
    - Expected outcome: Essential workflows remain usable without sync-required prompts or hard failures; feature shedding is predictable and documented.
    - Evidence: CI performance logs, throttling profiles, workflow completion output, degraded-mode screenshots.
    - MUST: NORM-028, NORM-032
- `DEG-A2` (Automated) 2G payload budget check
    - Preconditions: Performance harness able to measure initial HTML and first interaction on simulated 2G.
    - Steps: Throttle to 2G, load the baseline path, record initial HTML size and first usable interaction time, and fail the build if the declared budget is exceeded.
    - Expected outcome: The baseline path stays within the initial payload budget and remains functionally usable on 2G.
    - Evidence: HAR file, payload report, Lighthouse or equivalent budget artifact.
    - MUST: NORM-029
- `DEG-A3` (Automated) No media autoload trace
    - Preconditions: Network inspector enabled; pages containing media or attachments reachable.
    - Steps: Load the app and navigate baseline flows without explicitly requesting media. Inspect network traffic for image, audio, or video fetches.
    - Expected outcome: No media is requested until explicit user action occurs.
    - Evidence: HAR trace, network waterfall, UI recording of no-click navigation.
    - MUST: NORM-033
- `DEG-M1` (Manual) Low-memory device walkthrough
    - Preconditions: Older or emulated device with less than 512MB RAM target profile.
    - Steps: Complete the baseline critical workflow while monitoring crashes, jank, and memory pressure behavior.
    - Expected outcome: Core tasks finish without crashes or unusable slowdown on the target RAM floor.
    - Evidence: Device profile, screen recording, memory graph, crash logs.
    - MUST: NORM-030
- `DEG-M2` (Manual) Keyboard-only workflow walkthrough
    - Preconditions: No mouse or touch input; focus indicators visible; critical flows identified.
    - Steps: Navigate all critical flows using keyboard only, including complex widgets such as date pickers, charts, modals, and exports.
    - Expected outcome: Every interactive control is reachable and usable without a pointer; focus order remains logical throughout.
    - Evidence: Screen recording with keypress overlay, focus-order notes, blocked-control screenshots.
    - MUST: NORM-031
- `DEG-M3` (Manual) WCAG AA and screen reader audit
    - Preconditions: Assistive tech enabled; contrast tooling available; essential flows defined.
    - Steps: Run contrast, semantics, ARIA, labels, announcements, and screen-reader walkthroughs across all essential workflows.
    - Expected outcome: Critical workflows satisfy WCAG 2.1 AA requirements and remain understandable and operable with assistive technology.
    - Evidence: Accessibility audit report, screen-reader transcript, contrast screenshots, remediation notes.
    - MUST: NORM-034
- `DEG-U1` (Abuse) Resource-shock and hostile-network test
    - Preconditions: High latency, CPU throttling, low battery mode, and intermittent connectivity active.
    - Steps: Force the system into constrained conditions mid-workflow and observe whether it drops non-essential features first or collapses the essential path.
    - Expected outcome: The product degrades gracefully, preserving the critical path rather than failing wholesale.
    - Evidence: Video, performance timeline, network trace, degraded-mode state comparison.
    - MUST: NORM-028, NORM-032

### 6) Essential Utility

**Target user risk:** Engagement, monetization, and product-growth incentives displace survival-critical outcomes, creating manipulative friction and paywalled safety.

**Minimum system guarantees:** Every feature is tied to an essential use case or protective need, dark patterns are absent, addictive mechanics are excluded, success metrics follow user outcomes, and essential features are never paywalled.

**Measurable acceptance criteria**

- Every shipped feature has a documented justification tied to utility, safety, or accessibility.
- No essential workflow contains deceptive confirmations, retention nags, streaks, or upsell traps.
- Primary product metrics evaluate user goal completion, not time-on-app or feature adoption alone.

**Candidate tests (6)**

- `ESS-A1` (Automated) Feature-justification ledger gate
    - Preconditions: Versioned feature inventory and essential workflow ledger available.
    - Steps: Diff the current feature inventory against the justification ledger and fail if any feature lacks linkage to an essential workflow, protective requirement, or accessibility/safety obligation.
    - Expected outcome: No shipped feature exists without an explicit reason tied to user survival, autonomy, or accessibility.
    - Evidence: CI diff artifact, feature matrix, missing-link report.
    - MUST: NORM-035, NORM-037
- `ESS-A2` (Automated) Gamification and addictive mechanic scan
    - Preconditions: UI copy inventory, notification catalog, analytics config, feature flags.
    - Steps: Search runtime copy, config, and notification templates for streaks, variable rewards, leaderboards, FOMO nudges, and manipulative retention prompts.
    - Expected outcome: No addictive mechanic or engagement-maximizing loop appears in the shipped product or dormant flags intended for essential flows.
    - Evidence: Static scan output, copy inventory, notification diff, feature-flag report.
    - MUST: NORM-039
- `ESS-A3` (Automated) Metric inventory and decision-basis review
    - Preconditions: Access to product metrics, analytics dashboards, roadmap or PRD artifacts from recent releases.
    - Steps: Classify all primary and secondary metrics as outcome, engagement, or mixed; verify essential workflows have outcome metrics and roadmap decisions are justified by those outcomes.
    - Expected outcome: Primary success metrics are outcome-based; engagement metrics are secondary and not used to justify essential-path changes.
    - Evidence: Metric inventory, dashboard screenshots, PRD excerpts, decision trace notes.
    - MUST: NORM-040
- `ESS-M1` (Manual) Feature subtraction walkthrough
    - Preconditions: Feature flags or disable paths available; essential workflows enumerated.
    - Steps: Disable or hide the top non-essential candidate features, then re-run essential workflows to confirm utility and integrity remain intact.
    - Expected outcome: Removing non-essential features does not harm the essential path, proving the product surface is utility-first rather than feature-accumulative.
    - Evidence: Before/after screenshots, workflow results, disabled-feature list, subtraction notes.
    - MUST: NORM-035, NORM-037
- `ESS-M2` (Manual) Essential free-tier paywall check
    - Preconditions: Fresh free-tier account or unpaid user state; essential workflow list defined.
    - Steps: Complete every essential workflow as an unpaid user and attempt deep links directly into critical routes to detect hidden gating.
    - Expected outcome: No essential feature is paywalled, rate-limited to unusability, or blocked by entitlement checks.
    - Evidence: Screen recording, entitlement matrix, API responses, blocked-route screenshots if any.
    - MUST: NORM-041
- `ESS-U1` (Abuse) Dark-pattern adversarial probe
    - Preconditions: Attacker/product-growth perspective; access to onboarding, cancellation, export, deletion, and notification flows.
    - Steps: Attempt to coerce the user into continuing, sharing, paying, or disclosing more through deceptive defaults, misleading confirmation copy, or manipulative urgency.
    - Expected outcome: No deceptive friction, bait notifications, misleading confirmations, or forced-continuity tactics appear in essential workflows.
    - Evidence: Screenshots of every prompt, notification samples, flow notes, UX review log.
    - MUST: NORM-038

---

### MUST traceability matrix (by principle bundle)

| Spec MUST IDs | Mapped tests | Coverage note |
| --- | --- | --- |
| NORM-001, NORM-003, NORM-004, NORM-005, NORM-006 | REV-A1, REV-A2, REV-M1, REV-M2, REV-U1 | Undo paths, recovery windows, delayed deletion, published reversibility boundaries |
| NORM-007, NORM-010, NORM-011, NORM-012, NORM-013, NORM-014 | EXP-A1, EXP-A2, EXP-A3, EXP-M1, EXP-U1 | Field necessity, crypto at rest, TLS in transit, retention expiry, undisclosed sharing |
| NORM-015, NORM-017, NORM-018, NORM-019, NORM-020, NORM-021 | LOC-A1, LOC-A2, LOC-A3, LOC-M1, LOC-M2, LOC-U1 | Offline operation, local cache integrity, async sync, offline access without auth, documented parity |
| NORM-022, NORM-023, NORM-024, NORM-025, NORM-026, NORM-027 | COE-A1, COE-A2, COE-A3, COE-M1, COE-U1, COE-U2 | Zero-knowledge boundary, passphrase and KDF quality, no backdoors, truthful threat-model disclosure |
| NORM-028, NORM-029, NORM-030, NORM-031, NORM-032, NORM-033, NORM-034 | DEG-A1, DEG-A2, DEG-A3, DEG-M1, DEG-M2, DEG-M3, DEG-U1 | Constrained networks, low memory, keyboard-only operation, media loading, WCAG AA |
| NORM-035, NORM-037, NORM-038, NORM-039, NORM-040, NORM-041 | ESS-A1, ESS-A2, ESS-A3, ESS-M1, ESS-M2, ESS-U1 | Feature justification, anti-dark-pattern, anti-addiction, metric discipline, paywall checks |
| NORM-042 | GOV-01 | Compliance declaration resolves to weakest principle |

---

### Remediation Tracker

- Current blocker and remediation index: [REMEDIATION_ARTIFACT_LIST.md](REMEDIATION_ARTIFACT_LIST.md)
- Workspace limitation: this repository contains reference and audit artifacts for PainTracker, not the application implementation itself; unblocking the remaining Coercion Resistance and Degraded Functionality signoffs requires changes in the implementation repository plus fresh verification evidence.
- Local Authority evidence added: [LOCAL_AUTHORITY_OPERATING_PROFILE.md](LOCAL_AUTHORITY_OPERATING_PROFILE.md), [OFFLINE_PARITY_AND_SYNC_SPEC.md](OFFLINE_PARITY_AND_SYNC_SPEC.md)
- Coercion current-state artifacts added: [COERCION_BOUNDARY_MATRIX.md](COERCION_BOUNDARY_MATRIX.md), [COERCION_SAFE_MODE_DESIGN_BRIEF.md](COERCION_SAFE_MODE_DESIGN_BRIEF.md), [COERCION_SCENARIO_EVIDENCE_PACKET.md](COERCION_SCENARIO_EVIDENCE_PACKET.md)
- Coercion implementation threshold added: [DURESS_MODE_REQUIREMENTS_CHECKLIST.md](DURESS_MODE_REQUIREMENTS_CHECKLIST.md)
- Coercion implementation spec added: [DURESS_MODE_IMPLEMENTATION_SPEC.md](DURESS_MODE_IMPLEMENTATION_SPEC.md)
- Coercion routing design added: [DURESS_MODE_ROUTING_DESIGN.md](DURESS_MODE_ROUTING_DESIGN.md)
- Degraded remediation artifacts added: [DEGRADED_MODE_REMEDIATION_MATRIX.md](DEGRADED_MODE_REMEDIATION_MATRIX.md), [DEGRADED_MODE_REQUIREMENTS_CHECKLIST.md](DEGRADED_MODE_REQUIREMENTS_CHECKLIST.md), [DEGRADED_MODE_IMPLEMENTATION_SPEC.md](DEGRADED_MODE_IMPLEMENTATION_SPEC.md)
- Essential Utility evidence added: [FEATURE_JUSTIFICATION_MATRIX.md](FEATURE_JUSTIFICATION_MATRIX.md), [ESSENTIAL_UTILITY_SUBTRACTION_REPORT.md](ESSENTIAL_UTILITY_SUBTRACTION_REPORT.md)

---

### Audit-ready checklist (signoff)

- [x]  Stage 1 metadata and sitemap audit passes with zero failures.
- [x]  Stage 2 and Stage 3 semantic gates pass, including `WEAK_VERIFICATION_COUNT=0`.
- [x]  Essential workflows and threat scenarios for this audit are documented before testing begins.
- [x]  Reversibility signoff complete (evidence packet exists).
- [x]  Exposure Minimization signoff complete (evidence packet exists).
- [x]  Local Authority signoff complete (evidence packet exists).
- [ ]  Coercion Resistance signoff complete (evidence packet exists).
    Blocked: current-state evidence is published in [COERCION_BOUNDARY_MATRIX.md](COERCION_BOUNDARY_MATRIX.md), [COERCION_SCENARIO_EVIDENCE_PACKET.md](COERCION_SCENARIO_EVIDENCE_PACKET.md), and [COERCION_SAFE_MODE_DESIGN_BRIEF.md](COERCION_SAFE_MODE_DESIGN_BRIEF.md); implementation thresholds are defined in [DURESS_MODE_REQUIREMENTS_CHECKLIST.md](DURESS_MODE_REQUIREMENTS_CHECKLIST.md) and [DURESS_MODE_IMPLEMENTATION_SPEC.md](DURESS_MODE_IMPLEMENTATION_SPEC.md). Signoff remains blocked because [docs/spec/v1.0-must-justifications.html](docs/spec/v1.0-must-justifications.html) still marks NORM-022 as `Not Met`, and [docs/reference-implementation/paintracker-mapping.html](docs/reference-implementation/paintracker-mapping.html) still states that the system is not suitable for active-coercion scenarios.
- [ ]  Degraded Functionality signoff complete (evidence packet exists).
-    Blocked: current degraded-mode planning artifacts are published in [DEGRADED_MODE_REMEDIATION_MATRIX.md](DEGRADED_MODE_REMEDIATION_MATRIX.md), [DEGRADED_MODE_REQUIREMENTS_CHECKLIST.md](DEGRADED_MODE_REQUIREMENTS_CHECKLIST.md), and [DEGRADED_MODE_IMPLEMENTATION_SPEC.md](DEGRADED_MODE_IMPLEMENTATION_SPEC.md), but [docs/spec/v1.0-must-justifications.html](docs/spec/v1.0-must-justifications.html) still shows NORM-028 `Partial`, NORM-030 `Partial`, NORM-031 `Not Met`, NORM-032 `Partial`, and NORM-034 `Not Met`; [docs/reference-implementation/paintracker-mapping.html](docs/reference-implementation/paintracker-mapping.html) also still documents JavaScript dependency, incomplete keyboard navigation, and WCAG AA gaps.
- [x]  Essential Utility signoff complete (evidence packet exists).
- [ ]  `GOV-01`: Compliance declaration is explicit per principle and overall compliance resolves to the weakest principle.