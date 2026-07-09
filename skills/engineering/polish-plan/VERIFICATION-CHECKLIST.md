# Verification Checklist

Per-section verification mechanics. Use this as the lookup table when applying the three passes (`Existence + liveness`, `Assumption audit`, `Coding-principles`) to a plan section.

The plan sections below are the canonical sections of an `execution-plan` output. If the plan you're polishing uses different sections, adapt this list — the **mechanics** (verify, audit, apply principles) are the same; only the section names change.

---

## Context Snapshot

The "auto-discovered environment" header: tooling versions, runtime, key dependencies.

**Pass A — Existence + liveness:**

- Every version stated (Node version, Python version, Postgres version, etc.) matches the project's pinned version (`package.json`, `pyproject.toml`, `.tool-versions`, `Dockerfile`, CI config).
- Every tool mentioned (e.g. "uses `pnpm`") actually matches what the repo uses.

**Pass B — Assumption audit:**

- Any claim that doesn't appear in a config file (e.g. "Postgres 14 is available") is ungrounded by definition. Either verify against CI / infra docs, or flag as `BLOCK` if not.

**Pass C — Coding-principles:**

- `KISS`: does the snapshot list only what's load-bearing? Or is it a kitchen-sink dump that adds noise?
- `YAGNI`: anything listed that the plan doesn't actually depend on?

---

## Files to Read

The list of files the plan expects you to read before implementing.

**Pass A — Existence + liveness:**

- Every path resolves. No typos, no stale references to files that were renamed or deleted.
- Every path is in the repo (not an absolute filesystem path on the author's machine).

**Pass B — Assumption audit:**

- Every "with justification" actually justifies — the listed file is relevant to the implementation, not just nearby.
- No file is listed twice for different reasons.
- No file is critical to the plan but missing from the list.

**Pass C — Coding-principles:**

- `KISS`: are the right files listed for the right reasons? Or is the list bloated with "context" files the executor won't actually need?
- `DRY`: if the same file is listed under multiple sections, the list may have been authored without checking the others.

---

## Implementation Steps

The exact changes — commands, file edits, order.

**Pass A — Existence + liveness:**

- Every file mentioned in "create new" steps doesn't already exist (or the step is a deliberate overwrite, marked as such).
- Every file mentioned in "modify" steps exists.
- Every command is syntactically valid for the project's shell / package manager.
- Every command's working directory is correct (relative to repo root unless stated).

**Pass B — Assumption audit:**

- Each step has a stated outcome — what changes after running it.
- The order is sound — no step depends on the output of a later step.
- No step silently assumes the previous step succeeded (or if it does, that's marked).

**Pass C — Coding-principles:**

- `KISS`: is each step doing one thing? Or are multi-purpose steps (e.g. "install deps AND run migrations AND seed DB") asking the executor to debug three failures at once?
- `DRY`: if the same change is described in two steps, one is redundant.
- `SOLID`: the change respects module boundaries — no step reaches across seams that don't exist yet.
- `YAGNI`: no step implements a feature beyond what the change requires (no "while I'm here…").

---

## Test Plan

By layer: unit, integration, e2e.

**Pass A — Existence + liveness:**

- Every test path mentioned exists in the repo.
- Every test command runs the project's test runner correctly.
- Every fixture / mock referenced is actually defined somewhere.

**Pass B — Assumption audit:**

- Each test has a stated assertion — what it proves.
- The test pyramid is sound: unit tests cover logic, integration tests cover boundaries, e2e tests cover user flows. No layer is silently absent.
- No critical path is untested (e.g. the happy path, the failure path, the rollback path).

**Pass C — Coding-principles:**

- `KISS`: each test asserts one thing. Multi-purpose tests are hard to debug when they fail.
- `DRY`: shared fixtures / helpers are referenced, not re-implemented.
- `YAGNI`: no test exists for code that hasn't been written yet. Tests follow implementation, not the other way around (unless this is a TDD plan, in which case that's stated).

---

## E2E Verification

The user-visible check that the change actually works.

**Pass A — Existence + liveness:**

- The e2e tooling (Playwright, Cypress, manual curl, browser steps) exists and is runnable.
- Every URL / route mentioned in the e2e is reachable in the target environment.

**Pass B — Assumption audit:**

- The e2e exercises the *user-visible* behaviour the change is supposed to deliver — not an internal proxy that happens to be green.
- The e2e covers the failure case (what happens when the change is broken?), not just the happy path.
- The e2e is reproducible — anyone running it gets the same result.

**Pass C — Coding-principles:**

- `KISS`: the e2e is one focused flow, not a kitchen-sink "let's click everything" script.
- `YAGNI`: no e2e checks behaviour the change doesn't touch.

---

## Risks and Mitigations

The list of things that could go wrong, with how the plan handles each.

**Pass A — Existence + liveness:**

- Every mitigation is a concrete action, not "be careful" or "monitor closely".

**Pass B — Assumption audit:**

- Each risk is a *real* risk, not a generic disclaimer ("tests might fail").
- Each mitigation actually addresses the risk it claims to.
- The risks are ranked — what's most likely / most costly gets the most attention.

**Pass C — Coding-principles:**

- `KISS`: each risk + mitigation pair is one paragraph. Long-winded risk prose is usually padding.
- `YAGNI`: no risk is listed for behaviour the change doesn't introduce.

---

## Rollback Procedure

How to undo the change if it breaks production.

**Pass A — Existence + liveness:**

- Every rollback command runs the project's tooling correctly.
- Every "revert this file" reference points to a real file.

**Pass B — Assumption audit:**

- The rollback actually undoes the change. Not just "revert the commit" if the change is multi-step and partial state lingers (e.g. a DB migration ran but the code didn't deploy — reverting the code leaves the schema ahead of the code).
- The rollback is testable — the executor can dry-run it without committing.
- The rollback preserves data — doesn't drop a column that's still in use elsewhere.

**Pass C — Coding-principles:**

- `KISS`: the rollback is one clear procedure, not five conditional branches.
- `DRY`: if the change has multiple steps, the rollback mirrors the implementation steps in reverse.

---

## Execution Log

The living document the executor fills in during execution.

**Pass A — Existence + liveness:** N/A — this section is filled in during execution, not at plan time.

**Pass B — Assumption audit:**

- The section exists. If it's missing, it's a `New gap` (the executor will need somewhere to record what happened).
- The expected log format is stated (free-form prose? structured table? timestamped entries?).

**Pass C — Coding-principles:**

- `KISS`: the format is one of {prose, table, checklist}, not all three mixed.
- `YAGNI`: no log fields are required that the executor can't actually fill in.

---

## Cross-section patterns

Beyond per-section checks, look for cross-section issues:

- **Stale references.** A file mentioned in "Files to Read" but never used in "Implementation Steps" (or vice versa).
- **Mismatched ordering.** "Implementation Steps" assumes something from "Test Plan" runs first, but the section ordering implies the opposite.
- **Drift.** "Context Snapshot" lists Postgres 14; "Rollback Procedure" assumes Postgres 13 syntax.
- **Tone drift.** Some sections in imperative ("run `pnpm test`"), others in descriptive ("the tests will be run"). Pick one — recommend imperative, it's easier for the executor to follow.
- **Missing sections.** If a section is entirely absent (no Rollback Procedure, no Test Plan), it's a `New gap`, not silent acceptance.

## When a section type isn't in this list

The mechanics are universal:

1. **Existence + liveness.** Every claim is real and reachable.
2. **Assumption audit.** Every claim is grounded in code, docs, or `CONTEXT.md`.
3. **Coding-principles.** The design choices follow KISS / DRY / SOLID / YAGNI.

Apply the three passes to any section, even if it's not in this table. The table is a starting point, not an exhaustive list.