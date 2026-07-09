# Domino Reference

Detailed behavior for the `domino` skill. Loaded only when needed — `SKILL.md` covers the common path.

## Table of contents

- [Session start sequence](#session-start-sequence)
- [Logbook schema](#logbook-schema)
- [Preview template](#preview-template)
  - [Heuristic size notes](#heuristic-size-notes)
- [Recap line schema](#recap-line-schema)
- [Failure cascade (K=1)](#failure-cascade-k1)
- [Auto-decomposition](#auto-decomposition)
- [Mode handling](#mode-handling)
- [Revert behaviour](#revert-behaviour)
- [Feedback channel](#feedback-channel)
- [Security](#security)
- [Worked example](#worked-example)

## Session start sequence

### 0. Mode detection

Read the latest system reminder. If it contains the substring `Plan mode ACTIVE`, set the session's mode to PLAN. Otherwise set it to WRITE.

The detection runs at session start and again on every user turn. A flip mid-session (the reminder appearing or disappearing) is captured in the current domino entry's `Mode transitions:` field; the next preview re-derives its `Actions` frame to match the new mode.

If the reminder is absent (no plan-mode reminder found at all in the current turn), the skill assumes WRITE and surfaces the assumption visibly in the session header: `Mode: WRITE (auto-detected: no plan-mode reminder found — defaulting to WRITE)`. A silent default is observable, not hidden.

### 1. Light validation

Confirm:

- The plan file exists and is readable.
- It contains an `## Implementation Steps` section with at least one numbered step.

If either check fails, report the exact problem and stop. Do not proceed.

### 2. Logbook check

Look for an existing logbook at `<plan-dir>/<plan-basename>-domino-logbook.md`.

Examples:

- `PLAT1-3215-execution-plan.md` → `PLAT1-3215-execution-plan-domino-logbook.md`
- `2026-07-06-refactor-billing.md` → `2026-07-06-refactor-billing-domino-logbook.md`

If a logbook exists, ask:

```
A logbook already exists for this plan (last updated: <ISO timestamp>, last completed step: N of X).
  [R] Resume from step N+1
  [F] Start fresh (existing logbook will be archived with a timestamp suffix)
Reply R or F.
```

If absent, start fresh silently and print the session header.

### 3. Session header

```
=== DOMINO SESSION ===
Plan:   <plan file path>
Steps:  <total count after auto-decomposition>
Start:  <step 1, or N+1 if resuming>
Log:    <logbook file path>
Mode:   <PLAN | WRITE> (auto-detected: <Plan mode ACTIVE in latest reminder | no plan-mode reminder found — defaulting to WRITE>)
======================
```

### 4. Derive domino plan

Before any preview renders, run heuristic auto-decomposition against the plan's `## Implementation Steps`. Print the `## Derived Domino plan` block (see [Auto-decomposition](#auto-decomposition)) and wait for `c` (confirm) or `✎ <changes>` (redissect further).

In write mode, `c` launches the preview loop. In plan mode, `c` simply unlocks previews for inspection — `go` is not on the table.

### 5. First preview

Immediately present the first (or resumed) domino preview and wait.

## Logbook schema

The logbook is a separate file — never the plan itself. The plan file is the spec; the logbook is the record. They must not drift silently.

Append after each domino completes. Do not batch.

Per domino:

```markdown
### Domino N — <step name>

**Executed at:** <ISO 8601 timestamp>
**Mode:** PLAN | WRITE

**Status:** COMPLETED | FAILED | SKIPPED | PREVIEWED

**Mode transitions:** (always present; list or "none")
- <ISO timestamp> — PLAN → WRITE (cause: <e.g. "system reminder changed mid-session">)
- (none — session opened in PLAN and stayed there)

**Feedback history** (optional, only present if revisions happened):
- <ISO timestamp> — <class: EXPAND | REWRITE | REDIRECT>
  - User said: "<raw user message>"
  - Delta: <what changed vs the original plan preview>

**Auto-decomposition:** (optional, only present if heuristics split this step):
- <ISO timestamp> — heuristic trigger: command-count 7 > 5; file-scope 4 > 3
  - Split: Domino N → Domino Na + Domino Nb
  - Origin: skill (heuristic) | user (`## Domino boundaries` block) | combined

**Commands run** (post-feedback if any):
```
<exact commands, or [n/a — plan mode]>
```

**Output:**
```
<full output — never truncate, or [n/a — plan mode]>
```

**Verification:**
```
<verification command + output, or [n/a — plan mode]>
```

**Issues:** None | <description>
**Open:** None | <unresolved, carried forward into the next preview's `From N-1:` recap>

**Deviation from plan:** None | <what changed and why>

---
```

Session summary block, written once at end:

```markdown
## Session Summary

**Closed at:** <ISO 8601 timestamp>
**Completed:** N
**Skipped:** N
**Failed:** N
**Previewed:** N    (plan-mode entries with no execution)
**Logbook:** <logbook path>
**Mode at close:** PLAN | WRITE | MIXED
```

### Field provenance rules

- **`Mode`** is set once at session start. `WRITE` is the default; `PLAN` only when the latest reminder's mode-detection check succeeds at the first user turn.
- **`Status: PREVIEWED`** is a non-terminal state — a session closed in plan mode can be resumed in write mode, and `PREVIEWED` entries upgrade to `COMPLETED`/`FAILED`/`SKIPPED` on first execution.
- **`Mode transitions:`** always renders — either the explicit list (`PLAN → WRITE at <ISO>`) or `(none — session opened in <mode> and stayed there)`. Empty-but-absent is reserved for legacy logbooks; new entries never omit the field.
- **`Auto-decomposition:`** only renders when heuristics or a `## Domino boundaries` block produced an edit affecting this domino. The `Split` row records the index math (Domino N → Na + Nb) so a reviewer can reconstruct the upstream plan edit.
- **`Commands run`** / **`Output`** / **`Verification`** are present-but-`[n/a — plan mode]` for `PREVIEWED` entries rather than omitted. This keeps the schema row set identical across modes — only the values vary.

## Preview template

Every preview renders the same 64-character box-drawing layout. The shape is the contract; the slot text fills in from the plan + the previous post-exec.

### Design locks

- **Outer frame.** `╔═…═╗` opening + `╚═…═╝` mirror close, uniform 64-char width. The whole preview is one tall stack of frames.
- **Title-bar vocabulary.** Every inner frame uses a single noun (`┌─ From ─┐`, `┌─ What ─┐`, `┌─ Commands ─┐`, `┌─ Outcome / Risk / Revert ─┐`, `┌─ Actions ─┐`). The chain identifier (`Domino N-1`, status, age) migrates into From-frame's first content row, not the title.
- **Tri-card.** `Outcome / Risk / Revert` collapses into one frame with three glyph-prefixed rows: `✓ Outcome / ⚠ Risk / ↩ Revert`.
- **Actions glyph vocabulary.** Verb-glyph family: `▶ go`, `⊘ skip <reason>`, `■ stop`, `↩ revert`, `✎ <feedback>`. `↩` is shared between the status row (Revert) and the verb (revert) — same concept, same glyph.
- **Plan / Log exception.** Both stay as plain labels just outside the closing bar (chrome, not decision content).
- **Auto-bundle transition.** Post-exec closes the mirror `╚═…═╝`, a `── Next domino ──` banner sits between, and the next preview opens with its own `╔═…═╗`. On FAILED, the banner reads `── Replacement domino (depth 1 of 1) ──` — the depth annotation earns its keep where the eye lands.

### Rendered shapes

The four user-visible faces:

#### 1. First preview (N=1)

```
╔══════════════════════════════════════════════════════════════════╗
║  Domino 1 of X  ·  <step name>                                  ║
╚══════════════════════════════════════════════════════════════════╝

┌─ What ──────────────────────────────────────────────────────────┐
│ <one sentence — what this step does>                            │
└──────────────────────────────────────────────────────────────────┘

┌─ Commands ──────────────────────────────────────────────────────┐
│  1. <exact command>                                              │
│  2. <exact command>                                              │
│  …                                                               │
└──────────────────────────────────────────────────────────────────┘

┌─ Outcome / Risk / Revert ────────────────────────────────────────┐
│ ✓ Outcome   <what success looks like>                            │
│ ⚠ Risk      <Low | Medium | High> — <one-sentence justification> │
│ ↩ Revert    <Auto | Manual — brief description>                  │
└──────────────────────────────────────────────────────────────────┘

┌─ Actions ───────────────────────────────────────────────────────┐
│ ▶  go             Execute this domino                            │
│ ⊘  skip <reason>  Mark SKIPPED, advance                          │
│ ■  stop           Finalise logbook, exit                         │
│ ↩  revert         Undo last completed domino                     │
│ ✎  <feedback>     Re-derive this preview                         │
└──────────────────────────────────────────────────────────────────┘

Plan  <plan file path>
Log   <logbook file path>
```

(No `From` frame on N=1 — there is no prior domino.)

#### 2. Regular preview (N≥2, after COMPLETED)

```
╔══════════════════════════════════════════════════════════════════╗
║  Domino N of X  ·  <step name>                                   ║
╚══════════════════════════════════════════════════════════════════╝

┌─ From ──────────────────────────────────────────────────────────┐
│ Domino N-1  <STATUS>  <age stamp if >1h>                         │
│ Delivered  <≤8 words>                                            │
│ Verify     <count>                                               │
│ Open       <list or none>                                        │
└──────────────────────────────────────────────────────────────────┘

┌─ What ──────────────────────────────────────────────────────────┐
│ <one sentence — what this step does>                            │
└──────────────────────────────────────────────────────────────────┘

┌─ Commands ──────────────────────────────────────────────────────┐
│  1. <exact command>                                              │
│  2. <exact command>                                              │
│  …                                                               │
└──────────────────────────────────────────────────────────────────┘

┌─ Outcome / Risk / Revert ────────────────────────────────────────┐
│ ✓ Outcome   <what success looks like>                            │
│ ⚠ Risk      <Low | Medium | High> — <one-sentence justification> │
│ ↩ Revert    <Auto | Manual — brief description>                  │
└──────────────────────────────────────────────────────────────────┘

┌─ Actions ───────────────────────────────────────────────────────┐
│ ▶  go             Execute this domino                            │
│ ⊘  skip <reason>  Mark SKIPPED, advance                          │
│ ■  stop           Finalise logbook, exit                         │
│ ↩  revert         Undo last completed domino                     │
│ ✎  <feedback>     Re-derive this preview                         │
└──────────────────────────────────────────────────────────────────┘

Plan  <plan file path>
Log   <logbook file path>
```

#### 3. Auto-bundle transition after COMPLETED

```
✓ Outcome  <one sentence>
✓ Verify   <count>
✓ Open     <list or none>

╚══════════════════════════════════════════════════════════════════╝

── Next domino ────────────────────────────────────────────────────

╔══════════════════════════════════════════════════════════════════╗
║  Domino N+1 of X  ·  …                                          ║
╚══════════════════════════════════════════════════════════════════╝
… <body frames> …
```

#### 4. FAILED transition → replacement domino (K=1 cascade)

```
✓ Outcome  <one sentence>
✗ Verify   <verification failure summary>
✗ Open     <unfixed>

╚══════════════════════════════════════════════════════════════════╝

── Replacement domino (depth 1 of 1) ──────────────────────────────

╔══════════════════════════════════════════════════════════════════╗
║  Domino N'  ·  <replacement step name>                           ║
╚══════════════════════════════════════════════════════════════════╝

┌─ From ──────────────────────────────────────────────────────────┐
│ Domino N  FAILED  <age stamp if >1h>                             │
│ Root cause  <≤12 words>                                          │
│ Open        <unfixed>                                            │
└──────────────────────────────────────────────────────────────────┘

┌─ What ──────────────────────────────────────────────────────────┐
│ <one sentence — addresses the failure>                          │
└──────────────────────────────────────────────────────────────────┘

┌─ Commands ──────────────────────────────────────────────────────┐
│ <single tentative one-liner — agent's best guess>                │
└──────────────────────────────────────────────────────────────────┘

┌─ Outcome / Risk / Revert ────────────────────────────────────────┐
│ ✓ Outcome   <what success looks like>                            │
│ ⚠ Risk      <empty — user to fill or accept default>             │
│ ↩ Revert    <empty — user to fill or accept default>             │
└──────────────────────────────────────────────────────────────────┘

┌─ Actions ───────────────────────────────────────────────────────┐
│ ▶  go             Execute this tentative repair                  │
│ ⊘  skip <reason>  Mark SKIPPED, advance                          │
│ ■  stop           Finalise logbook — K=1 cap reached             │
│ ↩  revert         Undo last completed domino                     │
│ ✎  <feedback>     Re-derive this preview                         │
└──────────────────────────────────────────────────────────────────┘

Plan  <plan file path>
Log   <logbook file path>
```

#### 5. Plan-mode first preview (variant B)

Same geometry as shape 1 (first preview, N=1), with three additive chrome layers and a reduced Actions block:

- **Title bar:** the chain identifier row reads `Domino 1 of X  ·  <step name>` plus a `MODE: PLAN` suffix on the same line.
- **Actions divider:** the Actions frame ends with a `── mode: plan ──` row, then two reduced-mode rows (`✎  any input  re-derives this preview`, `■  stop  end session cleanly`). The full write-mode vocabulary above the divider is preserved for muscle-memory continuity across mode flips.
- **Chrome strip:** the `Plan <path>` / `Log <path>` strip grows a `Mode   PLAN` row, parallel to Plan and Log.

A worked example of the rendered shape and the four transformation rules live in [Mode handling](#mode-handling).

### Heuristic size notes

When a preview's `Commands` list exceeds the auto-decomposition thresholds (commands > 5 or file-scope > 3), Domino prefixes the chrome strip with an informational note:

```
Plan   ./plans/2026-07-06-auth-refactor.md
Log    ./plans/2026-07-06-auth-refactor-domino-logbook.md
Mode   WRITE
Note   oversized — 7 commands, 4 files; ✎ to redissect
```

Rules:

- The note is **informational**, not blocking. `go` is still accepted.
- The note renders *only* on the preview that would be oversized; downstream previews that depend on inherited commands do not re-render the note.
- Feedback that classifies as `REDIRECT` and reduces the command count below the threshold removes the note on the next re-derivation.
- Heuristic-driven auto-decomposition at session start has already split any oversized plan step before previews render — the note is for cases the heuristics missed (e.g. a user added commands via feedback after the split ran).

## Recap line schema

Every preview's first line is a `From N-1:` recap of the previous completed domino — omitted on N=1 (no prior domino). The recap pulls from the last post-exec report in the current session's memory, or from the logbook's last entry on resume.

When the previous domino is more than one hour old, the recap includes the age: `…, 6h ago`.

### COMPLETED

```
From Domino N-1 [COMPLETED at <sha>]: <delivery, ≤8 words>. Verify: <count>. Open: <list or none>.
```

`Open:` is populated only when the post-exec `Open:` field was non-empty. `None` or `<list>` — never both, never blank.

### SKIPPED

```
From Domino N-1 [SKIPPED]: <reason, ≤8 words>. No work performed; picking up the plan at Domino N.
```

Distinct verb from `COMPLETED`: the next preview depends on the skipped work being handled out-of-band, so the recap must be visually different from a successful one-liner.

### FAILED

```
From Domino N-1 [FAILED at <sha>]: <root cause, ≤12 words>. Open: <unfixed>.
```

Followed by a `Reason for proposal:` line and a drafted replacement domino. See [Failure cascade (K=1)](#failure-cascade-k1).

## Failure cascade (K=1)

When a post-exec report is `FAILED`, Domino drafts a single replacement domino before halting. Cascade depth is capped at **K=1**: a failed replacement halts the session; a second replacement is not drafted. The full rendered shape lives in [Preview template § 4](#preview-template); the section here pins down the rules.

### What the skill fills vs what the user fills

- **Skill fills:** `Step`, `What`, `Commands` (single tentative one-liner), `Outcome`. Derived from the post-exec `Open:` field plus the verification failure output.
- **User owns:** `Risk` and `Revert`. The agent has no reliable way to assess reversibility on a fresh step. Typing `go` accepts the empty/default fields; using `✎ <feedback>` lets the user author them before `go`.

### Depth annotation lives on the transition banner

`── Replacement domino (depth 1 of 1) ──` is printed on the auto-bundle banner between the previous post-exec's `╚═…═╝` and the replacement's `╔═…═╗`. The user's eye sees the cascade cap *before* the replacement preview opens, not buried parenthetically inside its title bar.

### Why K=1

Cascade depth >1 risks a runaway: a flapping failure (e.g., transient infra) gets multiple replacement dominos before the user sees what's happening. K=1 forces the user back into the loop on the second failure, where they pick the next move themselves.

## Auto-decomposition

The plan's `## Implementation Steps` are *suggested* domino boundaries. At session start, Domino applies four heuristic signals; any step exceeding a signal's threshold is split into smaller dominos before any preview renders.

### Signals and defaults

| Signal | Threshold | Trigger |
|---|---|---|
| Command count | > 5 commands | A single preview with too many shell calls. |
| File scope | > 3 distinct files | A domino touching many files at once. |
| Reversibility mix | any reversible + irreversible in same step | `git push` etc. gets its own domino because revert behaviour differs. |
| Time budget | > 2 file-writes + > 1 test-run | Combines writes with at least one test invocation. |

Thresholds are defaults; plan authors can override per-step via [the `## Domino boundaries` block](#the-domino-boundaries-plan-block).

### Splitting rules

- A split is **a first-class plan edit.** It fires the same `── Realigned downstream ──` banner as a user-driven redissection, but with a `── Auto-decomposed:` prefix on the banner so a reviewer of the logbook can tell at a glance which edits were authored by whom.
- Splits preserve the order of work — `git push` lands after `git commit` in the new sequence; commands before the irreversibility boundary stay before, commands after stay after.
- A split Domino's commands list is filled from the original step's commands, mapped to the split boundary. `Risk` and `Revert` are recomputed from the new scope; the user (or auto-default) fills them in as usual.
- The downstream `From N-1:` recap headers refresh automatically. The session-header `Steps:` count reflects post-split domino count.

### The `## Domino boundaries` plan block

Optional. Authors who already know the right domino boundaries can declare them in the plan:

```markdown
## Domino boundaries

- Steps 4–6 are one domino because the gates share one fixture.
- Step 7 is one domino — manual VACUUM, irreversible, deserves its own preview.
```

Rules:

- When present and non-empty, **`## Domino boundaries` overrides the heuristics entirely** for the steps it mentions.
- When `## Domino boundaries` and the heuristics disagree on a step, the heuristic whispers a one-line note in the same `## Derived Domino plan` block: `Note: heuristics suggested splitting Step N into N+N+1, but plan's "Domino boundaries" block kept it as one. Confirmed.`
- The block is case-sensitive (`## Domino boundaries` only — `## Domino Boundaries` or `## Boundaries` are not auto-detected and the override is missed).
- An empty block is treated as "no override" and the heuristics apply normally.

### Gating the user

After auto-decomposition (with any overrides applied), Domino prints:

```
## Derived Domino plan
Plan steps: 6    Derived dominos: 8    Auto-decomposed: 1
Changed: Step 4 — split into Domino 4a + 4b (command-count 7 > 5; file-scope 4 > 3).
Heuristics: command-count > 5 ✓ · file-scope > 3 ✓ · reversibility mixed ✓ · time-budget ok
Reply `c` to confirm, or `✎ <changes>` to redissect further before any preview renders.
```

If no heuristics trigger and no overrides exist, the block reads `No decomposition needed. Plan steps: N === Derived dominos: N.`

The user must reply `c` (confirm) before any preview renders. `✎ <changes>` re-runs the derivation with user-driven edits and re-displays the block. In plan mode, `c` is the only way to unlock previews — there is no `go`.

### Logbook capture

Every split (heuristic or user-override) appends to the affected domino entries' `Auto-decomposition:` block (see [Logbook schema](#logbook-schema)). Provenance distinguishes the source:

- `Origin: skill (heuristic)` — heuristic triggered the split.
- `Origin: user (## Domino boundaries block)` — plan-author override forced it.
- `Origin: combined` — both agreed.

## Mode handling

### What "mode" means here

Domino is mode-aware. The mode is determined per turn by reading the latest system reminder for the substring `Plan mode ACTIVE`. The two modes:

- **Plan mode** — agent is read-only. Domino renders previews, accepts feedback, never executes. Only `stop` works as a session-lifecycle verb.
- **Write mode** — agent can execute. Domino renders previews and `go` executes.

Mid-session flips (the reminder appearing or disappearing) are detected each turn and captured in the current domino entry's `Mode transitions:` logbook field; the next preview re-derives its `Actions` frame to match the new mode. The user never has to manually tell Domino the mode — it's read from the chat's state each turn.

### What changes in plan mode

In plan mode, a small set of behaviors differ from write mode. The full write-mode vocabulary stays in the `Actions` frame for muscle-memory continuity; the plan-mode reduced vocabulary appears below a `── mode: plan ──` divider:

| Behaviour | Write mode | Plan mode |
|---|---|---|
| `go` | Execute the domino | No-op (visible via the divider) |
| `skip <reason>` | Mark SKIPPED, advance | Rejected (execution verb) |
| `stop` | Finalise logbook, exit | Finalise logbook, exit (no `Session Summary` line — `PREVIEWED` count substituted for `Completed/Skipped/Failed`) |
| `revert` | Undo last completed domino | Rejected (execution verb) |
| `✎ <feedback>` | Re-derive this preview | Re-derive this preview (default input class) |
| `✎ any input` | Treated as feedback if it's not a recognised command | All non-empty input is feedback by default |
| Title bar chain row | `Domino N of X  ·  <step>` | …plus `·  MODE: PLAN` suffix |
| Chrome strip | `Plan <path>` / `Log <path>` | …plus `Mode PLAN` row |

The three mode-indicator locations (title bar suffix, Actions divider, chrome strip) are additive chrome — they don't disturb the 64-char box-drawing geometry of the four write-mode preview shapes. A flip mid-session just toggles each location.

### Plan-mode preview rendered shape (first preview, N=1)

```
╔══════════════════════════════════════════════════════════════════╗
║  Domino 1 of 7  ·  Detect stale snapshots in PVE ring buffer    ║
║  MODE: PLAN                                                     ║
╚══════════════════════════════════════════════════════════════════╝

┌─ What ──────────────────────────────────────────────────────────┐
│ Walk the snapshot namespace and report ages vs. the configured   │
│ retention window.                                                 │
└──────────────────────────────────────────────────────────────────┘

┌─ Commands ──────────────────────────────────────────────────────┐
│  1. pvesm list --content images --output-format json | jq …       │
│  2. for vm in $(jq …); do echo "$vm …"; done                     │
└──────────────────────────────────────────────────────────────────┘

┌─ Outcome / Risk / Revert ────────────────────────────────────────┐
│ ✓ Outcome   Per-VM age table printed, all rows < retention       │
│ ⚠ Risk      Low — read-only, no mutation                         │
│ ↩ Revert    n/a (read-only)                                      │
└──────────────────────────────────────────────────────────────────┘

┌─ Actions ───────────────────────────────────────────────────────┐
│ ▶  go             Execute this domino                            │
│ ⊘  skip <reason>  Mark SKIPPED, advance                          │
│ ■  stop           Finalise logbook, exit                         │
│ ↩  revert         Undo last completed domino                     │
│ ✎  <feedback>     Re-derive this preview                         │
│ ── mode: plan ───────────────────────────────────────────────────│
│ ✎  any input      re-derives this preview                        │
│ ■  stop           end session cleanly                            │
└──────────────────────────────────────────────────────────────────┘

Plan   ./plans/2026-07-06-auth-refactor.md
Log    ./plans/2026-07-06-auth-refactor-domino-logbook.md
Mode   PLAN
```

The shape at N≥2 is identical, except a `┌─ From ──…┐` frame appears first (per [Preview template Shape 2](#rendered-shapes)) and the recap header's `PREVIEWED` status replaces `COMPLETED` / `SKIPPED` / `FAILED` from the upstream entry.

### Feedback routes through the same channel

Plan-mode feedback uses the same in-flight feedback pipeline as write mode — see [Feedback channel](#feedback-channel). The only difference is that in plan mode, feedback is the default input class (no commands recognised apart from `stop`), so `EXPAND`/`REWRITE`/`REDIRECT` classifications apply as normal and the affected preview re-derives in place. `REDIRECT` feedback that mutates the plan still fires the `── Realigned downstream ──` banner and the corresponding `Mode transitions:`-style realignment accounting — the banner system is shared between user-driven redissection and the auto-decomposition path.

### Practical use

- **Preview-only walkthrough.** Invoke `/domino` in plan mode to inspect every rendered preview without executing. The session ends on `stop` or after every domino is `PREVIEWED`.
- **Plan redissection.** Plan mode is the one place where restructuring the plan *itself* via Domino is allowed (write mode rejects "restructure the whole plan" — see [Feedback channel > Edge cases](#edge-cases)). Use `REDIRECT` feedback in plan mode to insert / split / remove / rename / reorder steps; the downstream preview auto-bundles realigned.
- **Resume in write mode.** A logbook closed in plan mode can be resumed in write mode from any `PREVIEWED` entry — the recap behaves like a fresh session starting from that domino, and `go` now executes.

### EXPLORE-agent surface

If Domino's first turn delegates to an `explore` agent (per the executor pattern in `ai-execution`), the explore agent itself is read-only regardless of the parent's mode. Plan-mode invocations cannot use `explore` to look up files for accurate command-fill; if accurate preview-filling matters, the user should `stop` the plan-mode walkthrough after seeing the high-level preview, switch to write mode, and resume for accurate command-fill on each step.

## Revert behaviour

### Reversible steps

File edits, local builds, local image creation, dependency installs into project-local paths. Domino runs the inverse operation automatically and re-presents the original domino as the current one.

### Irreversible steps

`git push`, PR creation, remote deploys, anything that publishes to a remote system outside Domino's scope. Domino prints:

```
This step cannot be automatically reverted.
To undo manually: <exact manual steps from the plan's ## Rollback Procedure>
No automatic action taken. You are still at step N.
```

### When in doubt

If reversibility is ambiguous, default to *manual* — surface the rollback steps from the plan and let the user decide.

## Feedback channel

### What counts as feedback

Anything before `go` that isn't:

- A command: `go`, `yes`, `proceed`, `next`, `skip <reason>`, `stop`, `revert`.
- A malformed command echo (typo of a known command — ask for clarification instead of treating as feedback).

Natural-language corrections, requests to add work, requests to change the approach — all feedback. In plan mode every non-empty input is feedback by default — see [Mode handling > What changes in plan mode](#what-changes-in-plan-mode).

### Routing auto-decomposition through REDIRECT

Heuristic auto-decomposition (see [Auto-decomposition](#auto-decomposition)) edits the same way a `REDIRECT`-class feedback edit does — it mutates the plan, fires the same `── Realigned downstream ──` banner, and captures the change in `Auto-decomposition:` logbook fields (parallel to `Feedback history`). The two pathways are visually distinguished by the banner prefix:

- User-driven redissection: `── Realigned downstream (steps N..M refreshed) ──`
- Skill-driven decomposition: `── Auto-decomposed: Step N split into Na + Nb ──`

A combined edit (heuristic triggered + user refined) renders both banners in sequence and the logbook's `Auto-decomposition:` block records `Origin: combined`.

### Classification rules

| Class | When to use | Recomputed fields |
|---|---|---|
| `EXPAND` | Add commands to the current domino; outcome unchanged. Example: *"also run the linter on these files before committing."* | `Commands`, possibly `Outcome` clarifier |
| `REWRITE` | Swap the commands but keep the same outcome. Example: *"do it via the API instead of the CLI."* | `Commands`, possibly `Risk` |
| `REDIRECT` | Change the outcome itself. Example: *"actually I want the JSON output, not the CSV."* | `Outcome`, `Commands`, `Risk`, `Revert` |

If two classes apply (e.g., the user's message both rewrites and redirects), pick the highest-impact class and note the secondary change in `Delta`.

### Multiple feedback rounds

The preview may be revised any number of times before `go`. Each round appends an entry to `Feedback history`. The `Commands run` block at completion records the final post-feedback commands.

### Edge cases

- **Contradicting feedback across rounds.** The latest `go` carries forward to the most recent preview. Earlier rounds stay in `Feedback history` for audit.
- **Out-of-scope feedback.** If the user's request can't be honoured by mutating the current domino (e.g., *"let's restructure the whole plan"*), Domino explains the limit and suggests `stop` + manual plan edits + re-invoking `/domino`.
- **Ambiguous feedback.** Ask one clarifying question rather than guessing the class.

### What is NOT feedback

- Questions about the plan (`"why does step 4 do X?"`) — answer from the plan, don't mutate the preview.
- Reporting a failure from a previous domino — `revert` or `retry`, not feedback.

## Security

- Never expose secrets, tokens, or credentials in logbook output. If a command output contains a secret, redact it as `[REDACTED]` in the logbook.
- Never commit the logbook or plan to git unless explicitly instructed.
- Treat the plan file as read-only during a session; revisions live in the logbook only.

## Worked example

Plan:

```markdown
## Implementation Steps

1. Commit the auth refactor.
2. Open PR against `main`.
3. Wait for CI.

## Handoff

After CI is green: ping @alice for review.

## E2E Verification

PR URL exists, CI is green, reviewer assigned.
```

### Session

```
=== DOMINO SESSION ===
Plan:   ./plans/2026-07-06-auth-refactor.md
Steps:  3
Start:  1
Log:    ./plans/2026-07-06-auth-refactor-domino-logbook.md
======================

--- Domino 1 of 3 ---
Step:     Commit the auth refactor
What:     Stage and commit the current changes with a descriptive message.
Commands:
  git add -A
  git commit -m "refactor(auth): extract token validation"
Outcome:  One new commit on the current branch; `git log -1` shows the expected message.
Risk:     Low — local-only, reversible via `git reset`.
Revert:   Auto — `git reset --soft HEAD~1`.

Say 'go' to execute. Or 'skip <reason>', 'stop', 'revert', or send feedback.
```

User: *"actually, also run the linter on the changed files first."*

Domino classifies as `EXPAND`. Recomputed preview:

```
--- Domino 1 of 3 (revised — EXPAND) ---
Step:     Commit the auth refactor
What:     Run the project linter on the changed files, then stage and commit.
Commands:
  npx eslint $(git diff --name-only HEAD~0)
  git add -A
  git commit -m "refactor(auth): extract token validation"
Outcome:  Linter passes (or reports only pre-existing issues), then one new commit.
Risk:     Low — local-only, reversible.
Revert:   Auto — `git reset --soft HEAD~1`.

Say 'go' to execute. Or 'skip <reason>', 'stop', 'revert', or send feedback.
```

User: *"use `git status` to discover the changed files instead — `git diff --name-only HEAD~0` is empty if there are no staged or unstaged changes."*

Domino classifies as `REWRITE` (same outcome, different commands). Recomputed preview:

```
--- Domino 1 of 3 (revised — REWRITE) ---
Step:     Commit the auth refactor
What:     Run the linter on files reported by `git status`, then stage and commit.
Commands:
  npx eslint $(git status --porcelain | awk '{print $2}')
  git add -A
  git commit -m "refactor(auth): extract token validation"
Outcome:  Linter passes, then one new commit.
Risk:     Low — local-only.
Revert:   Auto — `git reset --soft HEAD~1`.

Say 'go' to execute. Or 'skip <reason>', 'stop', 'revert', or send feedback.
```

User: *"go"*

Domino executes the linter, then the commit, and prints the post-execution report. The logbook entry:

```markdown
### Domino 1 — Commit the auth refactor

**Executed at:** 2026-07-06T14:22:11Z
**Status:** COMPLETED

**Feedback history:**
- 2026-07-06T14:21:48Z — EXPAND
  - User said: "actually, also run the linter on the changed files first."
  - Delta: Added `npx eslint $(git diff --name-only HEAD~0)` before `git add`.
- 2026-07-06T14:21:55Z — REWRITE
  - User said: "use `git status` to discover the changed files instead — ..."
  - Delta: Replaced the file-discovery mechanism; commands list otherwise unchanged.

**Commands run** (post-feedback):
```
npx eslint $(git status --porcelain | awk '{print $2}')
git add -A
git commit -m "refactor(auth): extract token validation"
```

**Output:**
```
[main abc1234] refactor(auth): extract token validation
 4 files changed, 88 insertions(+), 42 deletions(-)
```

**Verification:**
```
$ git log -1 --pretty=%s
refactor(auth): extract token validation
```

**Issues:** None
**Deviation from plan:** Linter invocation added per user feedback.

---
```

Then Domino previews Domino 2 (Open PR) and waits. From there the user could send a `REDIRECT` (e.g., *"open it against `release/2.x`, not `main`"*) instead of `go`, which would re-preview step 2 with `Outcome: PR targets release/2.x` and a matching base-branch flag in the command.

### FAILED → replacement domino

Continuing the same plan. Domino 2 (Open PR) executes but the GH CLI returns 401 (the user's token expired). The post-exec writes `Open: gh token expired; PR not opened`. Domino halts:

```
╔══════════════════════════════════════════════════════════════════╗
║  Domino 2 of 3  ·  Open PR against `main`                       ║
╚══════════════════════════════════════════════════════════════════╝

┌─ From ──────────────────────────────────────────────────────────┐
│ Domino 1  COMPLETED  5 min ago                                  │
│ Delivered  commit + linter clean                                │
│ Verify     14/14 preflight green                                 │
│ Open       none                                                 │
└──────────────────────────────────────────────────────────────────┘
… (rest of preview body) …

go
```

Output: `401 Unauthorized`. The post-exec closes the frame, then the FAILED-transition banner + replacement preview appears:

```
✓ Outcome  gh pr create exited 401
✗ Verify   gh auth: token expired
✗ Open     gh token expired; PR not opened

╚══════════════════════════════════════════════════════════════════╝

── Replacement domino (depth 1 of 1) ──────────────────────────────

╔══════════════════════════════════════════════════════════════════╗
║  Domino 2'  ·  Refresh gh token and retry PR creation            ║
╚══════════════════════════════════════════════════════════════════╝

┌─ From ──────────────────────────────────────────────────────────┐
│ Domino 2  FAILED  just now                                      │
│ Root cause  gh auth returned 401                                │
│ Open        gh token expired; PR not opened                     │
└──────────────────────────────────────────────────────────────────┘

┌─ What ──────────────────────────────────────────────────────────┐
│ Refresh the gh CLI token, then re-run the original PR command.  │
└──────────────────────────────────────────────────────────────────┘

┌─ Commands ──────────────────────────────────────────────────────┐
│  1. gh auth refresh                                              │
│  2. gh pr create --base main …                                  │
└──────────────────────────────────────────────────────────────────┘

┌─ Outcome / Risk / Revert ────────────────────────────────────────┐
│ ✓ Outcome   gh pr create exits 0; PR is open against main.      │
│ ⚠ Risk      <empty>                                             │
│ ↩ Revert    <empty>                                             │
└──────────────────────────────────────────────────────────────────┘

┌─ Actions ───────────────────────────────────────────────────────┐
│ ▶  go             Execute this tentative repair                  │
│ ✎  <feedback>     Re-derive this preview                         │
│ ■  stop           Finalise logbook — K=1 cap reached             │
└──────────────────────────────────────────────────────────────────┘

Plan  ./plans/2026-07-06-auth-refactor.md
Log   ./plans/2026-07-06-auth-refactor-domino-logbook.md
```

User: `go`

The skill runs the merged command, the PR opens, the post-exec is `COMPLETED`, and the From-frame on the next preview reads:

```
┌─ From ──────────────────────────────────────────────────────────┐
│ Domino 2  COMPLETED  just now                                   │
│ Delivered  gh auth refreshed + PR opened                         │
│ Verify     PR URL printed                                        │
│ Open       none                                                 │
└──────────────────────────────────────────────────────────────────┘
```

If that post-exec were also `FAILED`, Domino would halt; no second replacement would be drafted.
