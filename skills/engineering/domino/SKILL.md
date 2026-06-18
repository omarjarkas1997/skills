---
name: domino
description: Execute a pre-existing plan interactively, one step at a time, with a hard confirmation gate before each step. /domino <path-to-plan> runs a plan file step by step.
---

# Domino — Interactive Step-by-Step Executor

Execute a pre-existing plan one domino at a time. You are always in control. Nothing executes until you say `go`.

## What Domino Is

Domino is a strict executor of plans you have already grilled and approved. It never creates plans. It never combines or splits steps. It executes exactly one Implementation Step from the plan per domino, shows you what it did, then waits for you to tip the next one.

## What Domino Is Not

- Not a planner — use `/execution-plan` to create the plan first
- Not a batch executor — use `ai-execution` if you want a full handoff without staying in the loop
- Not an interpreter — Domino follows the plan exactly, documenting any deviation explicitly

---

## Invocation

```
/domino path/to/PLAT1-XXXX-execution-plan.md
```

---

## Session Start Sequence

### 1. Light Validation
Confirm:
- The plan file exists and is readable
- It contains an `## Implementation Steps` section with at least one numbered step

If either check fails: report the exact problem and stop. Do not proceed.

### 2. Logbook Check
Look for an existing logbook file at: `<plan-dir>/<plan-basename>-domino-logbook.md`

Example: `PLAT1-3215-execution-plan.md` → `PLAT1-3215-execution-plan-domino-logbook.md`

If a logbook exists, ask:
```
A logbook already exists for this plan (last updated: <timestamp>, last completed step: N of X).
  [R] Resume from step N+1
  [F] Start fresh (existing logbook will be archived with a timestamp suffix)
Reply R or F.
```

If no logbook exists: start fresh silently.

### 3. Session Header
Print:
```
=== DOMINO SESSION ===
Plan:   <plan file path>
Steps:  <total count>
Start:  <step 1 or N+1 if resuming>
Log:    <logbook file path>
======================
```

### 4. First Domino Preview
Immediately present the first (or resumed) domino preview and wait.

---

## The Domino Loop

### Preview (before every step)

```
--- Domino N of X ---
Step:     <step name from plan>
What:     <one sentence — what this step does>
Commands: <exact tool calls or bash commands I will run>
Outcome:  <what success looks like>
Risk:     <Low / Medium / High> — <one sentence justification>
Revert:   <Automatic / Manual — brief description>

Say 'go' to execute. Or ask questions, request changes, or 'skip <reason>' / 'stop'.
```

The gate is hard. Nothing executes until you say `go` (or an unambiguous equivalent: `yes`, `do it`, `proceed`).

### Execution
Execute exactly what was previewed. No additions, no shortcuts.

During execution, append a running entry to the logbook file in real time (do not wait until the step is complete to write).

### Post-Execution Report

```
--- Domino N complete ---
Status:       COMPLETED / FAILED / SKIPPED
What I did:   <brief summary>
Verification: <command run + output confirming the outcome>
Issues:       None / <description>
```

If status is FAILED: show the full error output, then wait for instruction. Do not auto-retry. Do not proceed to the next domino. Options available to the user: retry, skip, abort, or "try X instead".

If status is COMPLETED or SKIPPED: immediately present the next domino preview (or the session end sequence if this was the last step).

---

## Command Vocabulary

| Command | Effect |
|---|---|
| `go` / `yes` / `proceed` | Execute the current domino |
| `next` | Alias for `go` after a completed step (moves to the next preview) |
| `stop` | Pause session, finalize logbook, exit cleanly |
| `skip <reason>` | Mark current domino SKIPPED with the given reason, move to next preview |
| `revert` | Undo the last completed domino. If reversible: execute the rollback and re-present that domino as current. If not reversible: explain exactly what manual action is needed and stay put. |

---

## Logbook Format

The logbook is a separate markdown file — never the plan itself. It is the record of what happened; the plan is the spec of what was intended.

Append after each domino completes (do not batch):

```markdown
### Domino N — <step name>
**Executed at:** <ISO 8601 timestamp>
**Status:** COMPLETED / FAILED / SKIPPED

**Commands run:**
```
<exact commands>
```

**Output:**
```
<full output — never truncate>
```

**Verification:**
```
<verification command + output>
```

**Issues:** None / <description>
**Deviation from plan:** None / <what changed and why>
```

---

## Session End Sequence

When all dominos are complete (or `stop` is called):

1. Print summary:
   ```
   Skipped:   N steps
   Failed:    N steps
   Log:       <logbook file path>
   ================================
   ```

2. **Logbook finalised** — write a `## Session Summary` block to the logbook with the same counts and a timestamp.

3. **Offer plan Execution Log update**
   ```
   Update the plan's ## Execution Log section with a link to this logbook? (y/n)
   ```
   If yes: append a timestamped one-liner to the plan's `## Execution Log` section:
   `[<date>]: Domino session complete — see <logbook filename> for full log.`

4. **Surface manual handoff steps** — read the plan's `## Handoff` and `## E2E Verification` sections verbatim and print them:
   ```
   === MANUAL STEPS REQUIRED ===
   <contents of ## Handoff section>

   === E2E VERIFICATION ===
   <contents of ## E2E Verification section>
   ==============================
   ```
   Print these even if steps failed or were skipped. They represent things a human must do regardless.

---

## Failure Handling

When a domino fails:

1. Mark as FAILED in the logbook immediately
2. Show the full error output (never truncate)
3. Print:
   ```
   --- Domino N FAILED ---
   Error: <full error>

   Options:
     retry           — try the step again as-is
     skip <reason>   — mark SKIPPED and move on
     stop            — exit and preserve logbook state
     or tell me what to try differently
   ```
4. Wait. Do not retry automatically. Do not proceed.

---

## Revert Behaviour

Reversible steps (file edits, local builds, local image creation): Domino executes the inverse operation automatically and re-presents the step as the current domino.

Irreversible steps (git push, PR creation, remote deploys): Domino prints:
```
This step cannot be automatically reverted.
To undo manually: <exact manual steps from the plan's ## Rollback Procedure>
No automatic action taken. You are still at step N.
```

---

## Security

- Never expose secrets, tokens, or credentials in logbook output
- If a command output contains a secret, redact it as `[REDACTED]` in the logbook
- Never commit the logbook or plan to git unless explicitly instructed
