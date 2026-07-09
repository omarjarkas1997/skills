---
name: domino
description: Execute an approved plan interactively one domino at a time, with a hard `go` gate, in-flight feedback channel, `From N-1:` recap, K=1 failure cascade, plan/write-mode awareness (no execution in plan mode), and heuristic auto-decomposition of oversized plan steps at session start. Use when the user types /domino <path-to-plan>, or asks to run a plan 'step by step', 'one step at a time', or to 'confirm each step' before executing.
---

# Domino — Interactive Step-by-Step Executor

Execute a pre-existing plan one domino at a time. You are always in control. Nothing executes until you say `go`. Anything before `go` can be a `go`, a command (`skip` / `stop` / `revert`), or feedback that re-derives the current domino.

## What Domino is not

- Not a planner — use `execution-plan` to create the plan first.
- Not a batch executor — use `ai-execution` for unattended handoff.
- Not an interpreter — Domino follows the plan exactly, documenting any deviation inline.

## Modes

Domino runs in two modes, detected per turn by reading the latest system reminder for the substring `Plan mode ACTIVE`:

- **Plan mode** (read-only). The skill renders previews, accepts feedback that re-derives the current domino in place, and never executes. Only `stop` works as a session-lifecycle verb. Use this for previewing before committing to execution, or for walking plans the user wants to redissect.
- **Write mode** (default, full execution). Previews render and `go` executes the commands.

When the latest reminder doesn't contain `Plan mode ACTIVE`, the skill assumes write mode and surfaces the assumption in the session header: `Mode: WRITE (auto-detected: no plan-mode reminder found — defaulting to WRITE)`. A silent default is observable, not hidden.

Mid-session mode flips (the reminder changing between turns) are captured in the current domino's `Mode transitions:` logbook field, and the next preview re-derives its `Actions` frame to match the new mode.

In plan mode, the `Actions` frame shows the full write-mode vocabulary at the top (for muscle memory across flips) plus a `── mode: plan ──` divider and the reduced plan-mode vocabulary below it:

```
▶  go             Execute this domino
⊘  skip <reason>  Mark SKIPPED, advance
■  stop           Finalise logbook, exit
↩  revert         Undo last completed domino
✎  <feedback>     Re-derive this preview
── mode: plan ───────────────────────────────────────────────────
✎  any input      re-derives this preview
■  stop           end session cleanly
```

### Derive domino plan

After the logbook check and before the first preview, Domino runs heuristic auto-decomposition against the plan's `## Implementation Steps` and prints a `## Derived Domino plan` block:

```
## Derived Domino plan
Plan steps: 6    Derived dominos: 8    Auto-decomposed: 1
Changed: Step 4 — split into Domino 4a + 4b (command-count 7 > 5; file-scope 4 > 3).
Heuristics: command-count > 5 ✓ · file-scope > 3 ✓ · reversibility-mixed · time-budget ok
Reply `c` to confirm, or `✎ <changes>` to redissect further before any preview renders.
```

If no heuristics trigger, the block reads `No decomposition needed. Plan steps: N === Derived dominos: N.` If the plan contains an optional `## Domino boundaries` block (e.g. `Step 4 is one domino because the gates share one fixture`), that block overrides heuristic decomposition for the steps it mentions; when the override disagrees with a heuristic, the heuristic whispers a one-line note in the same block.

Decomposition is a first-class plan edit: any split fires the `── Auto-decomposed: … ──` realignment banner (parallel to the user-driven `── Realigned downstream ──`) and is captured in the new `Auto-decomposition:` field of the affected domino entries in the logbook. Full rules in [REFERENCE.md#auto-decomposition](./REFERENCE.md#auto-decomposition).

## Invocation

```
/domino <path-to-plan>
```

First argument is the path to the plan file. Relative paths resolve against the project root.

## Session Start

1. Validate: the plan file is readable and contains an `## Implementation Steps` section with at least one numbered step.
2. Check for an existing logbook at `<plan-dir>/<plan-basename>-domino-logbook.md`. If one exists, ask `[R]esume from next step / [F]resh (archive existing)`. If absent, start fresh.
3. Detect mode — see [## Modes](#modes) for the rule. Surface the detection result in the session header.
4. Run heuristic auto-decomposition and print the `## Derived Domino plan` block — see [## Modes > Derive domino plan](#derive-domino-plan). Wait for `c` or `✎ <changes>` before any preview renders.
5. Print the session header (mode, plan, derived dominos + logbook path) and the first preview. Wait.

## The Domino Loop

### Preview

Before every step. The full rendered template lives in [REFERENCE.md#preview-template](./REFERENCE.md#preview-template); the shape in outline:

- **Outer frame:** `╔═…═╗` opening + `╚═…═╝` mirror close, 64 chars wide. The whole preview is one stack of frames.
- **Inner frames:** `┌─ <noun> ─…─┐` for `From` (omitted on N=1), `What`, `Commands`, `Outcome / Risk / Revert`, `Actions`. Vocabulary nouns only — the chain identifier (`Domino N-1`, status, age) migrates into From-frame's first content row, not the title.
- **Tri-card:** `Outcome / Risk / Revert` collapses into one frame with three glyph-prefixed rows: `✓ Outcome / ⚠ Risk / ↩ Revert`.
- **Actions glyphs:** verb-glyph family `▶ go / ⊘ skip <reason> / ■ stop / ↩ revert / ✎ <feedback>`. `↩` is shared with the Revert status row (same concept, same glyph).
- **Heuristic note (optional):** when the preview's Commands list exceeds the auto-decomposition thresholds (commands > 5 or file-scope > 3), the chrome strip above `Plan`/`Log` carries `Note: oversized — ✎ to redissect`. Informational; doesn't block `go`.
- **Plan / Log exception:** plain labels just outside the closing bar (chrome, not decision content).

The gate is hard. Nothing executes until the input is `go`, `yes`, `proceed`, `next`, or an unambiguous equivalent.

### Three classes of user input

| Input | Effect |
|---|---|
| `go` / `yes` / `proceed` / `next` | Execute the current domino as previewed |
| `skip <reason>`, `stop`, `revert` | See `## Command vocabulary` and [REFERENCE.md](./REFERENCE.md#revert-behaviour) |
| Anything else | **Feedback** — see below |

### Feedback channel

User input before `go` that isn't a recognised command is feedback. Domino:

1. Classifies the feedback as `EXPAND`, `REWRITE`, or `REDIRECT`.
2. Recomputes only the affected preview fields (defaults: `Commands`, `Outcome`, `Risk`, `Revert`).
3. Appends a `Feedback history` block to the current logbook entry stub.
4. Re-presents the refreshed preview and waits. The user's next `go` carries forward to the recomputed version.

Completed domino entries are locked in the logbook — revisions influence upcoming work, never rewrite history.

### Recap channel

Every preview's first line is a `From N-1:` recap of the previous completed domino — absent on N=1 (no prior domino). Three shapes drive the next preview's heading:

- `COMPLETED` — `From Domino N-1 [COMPLETED at <sha>]: <delivery, ≤8 words>. Verify: <count>. Open: <list or none>.`
- `SKIPPED` — `From Domino N-1 [SKIPPED]: <reason, ≤8 words>. No work performed; picking up the plan at Domino N.`
- `FAILED` — `From Domino N-1 [FAILED at <sha>]: <root cause, ≤12 words>. Open: <unfixed>.` followed by a `Reason for proposal:` line and a drafted replacement domino (depth = 1 of 1; further failures halt).

The recap pulls from the last post-exec report. On resume from a logbook, it pulls from the logbook's last entry instead. When the previous domino is more than one hour old, the recap includes the age: `…, 6h ago`.

On `COMPLETED` or `SKIPPED`, Domino prints the next Domino N+1 preview in the same response (auto-bundle). Nothing executes until the user says `go`. On `FAILED`, Domino halts and drafts one replacement domino (see schema in [REFERENCE.md](./REFERENCE.md#recap-line-schema) and cascade rules in [REFERENCE.md](./REFERENCE.md#failure-cascade-k1)).

### Post-execution report

The post-exec closes the current preview's frame before bundling the next step:

```
--- Domino N complete ---
Status:       COMPLETED | FAILED | SKIPPED
What I did:   <brief summary>
Verification: <command run + output confirming the outcome>
Issues:       None | <description>           (closed-in-this-step notes)
Open:         None | <unresolved, blocks next domino>   (carried into the next recap)

╚══════════════════════════════════════════════════════════════════╝

── Next domino ────────────────────────────────────────────────────
   (or, on FAILED: ── Replacement domino (depth 1 of 1) ──────────)

╔══════════════════════════════════════════════════════════════════╗
║  Domino N+1 of X  ·  …                                          ║
╚══════════════════════════════════════════════════════════════════╝
…
```

`COMPLETED` / `SKIPPED` → next preview auto-bundled in this response (see ## Recap channel).
`FAILED` → halt; one replacement domino drafted (see ## Recap channel).

### Session End

When all dominos are complete (or `stop`):

1. Print skipped/failed counts.
2. Finalise `## Session Summary` in the logbook.
3. Offer to append a one-liner to the plan's `## Execution Log`.
4. Surface `## Handoff` and `## E2E Verification` from the plan verbatim, even on failures or skips.

## Command vocabulary

| Command | Effect |
|---|---|
| `go` / `yes` / `proceed` / `next` | Execute the current domino |
| `stop` | Pause session, finalise logbook, exit cleanly |
| `skip <reason>` | Mark current domino SKIPPED, advance |
| `revert` | Undo last completed domino (auto if reversible, manual if not) |

## Detailed behavior

See [REFERENCE.md](./REFERENCE.md) for: full session start sequence, logbook schema, revert taxonomy, feedback-channel edge cases and classification rules, security notes, and a worked example.
