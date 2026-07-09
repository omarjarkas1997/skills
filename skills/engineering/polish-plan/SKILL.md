---
name: polish-plan
description: Polish a draft plan (often from a smaller model or another agent) to the standard of a better model without redoing the work. Verifies file paths and assumptions, applies coding-principles, re-grills on factual gaps only. Edits the plan in place and emits a sibling changelog grouped into Improved / Verified (no change) / New gaps.
argument-hint: "<plan-path> [--deep]"
---

# Polish Plan

Take a draft plan and lift it to a better-model standard — without redoing the work the dumber model already did. The premise: the bulk of a plan (sections, structure, sequencing) is grunt work a smaller model can produce. What it lacks is verification, principle-discipline, and grounded assumptions. This skill is the bigger-model pass that fills in those gaps and leaves the bulk alone.

You are a **skeptical editor**, not a judge. You improve; you don't verdict.

## When to use

- After `execution-plan` produces a plan, before `domino` or `ai-execution` runs it.
- Any time you have a draft plan (yours, another agent's, or a peer's) and want it checked end-to-end before execution.

Do NOT use on:

- A plan you just wrote yourself in this same session — you don't need to polish your own fresh output.
- A plan that's fundamentally wrong in approach. `polish-plan` uplifts the *draft*. If the approach itself is wrong, escalate to `grill-with-docs` from scratch instead.

## Inputs

- **Required:** a path to a plan file (typically `docs/AI_EXECUTION_PLAN_<TASK>.md`).
- **Optional flag:** `--deep` enables adversarial red-team verification on top of the default three passes.

If no path is given and a plan was just pasted into the chat, treat the chat content as the plan (paste-fallback). Tell the user which mode you're in.

## The premise: trust nothing, verify everything

The dumber model wrote the bulk. You are the bigger model with file access. For every claim in the plan:

1. **Could I verify it?** Read the file, run the command, check the doc. If yes, do so.
2. **If I couldn't verify it, is it factual or a value judgement?** Factual claims are grills. Value judgements are `ASSUMED:`.
3. **Is the section already good?** If so, leave it and document the verification in the changelog — don't waste tokens rewriting good work.

Default to *not* editing. The plan's bulk is the dumber model's contribution; honour it.

## Process

### 1. Snapshot the original

Before any edits, copy the plan to a sibling file:

```
<plan-path>.original.md
```

This is your rollback path. If your edits go wrong, the diff is `diff <plan-path>.original.md <plan-path>` and the rollback is one `mv`.

### 2. Read the plan once, build a section map

Walk the plan top-to-bottom. Build an internal map of every section (e.g. `Context Snapshot`, `Files to Read`, `Implementation Steps`, `Test Plan`, `E2E Verification`, `Risks and Mitigations`, `Rollback Procedure`, `Execution Log` — or whatever the plan uses).

Do NOT re-read sections you've already mapped. Token budget.

### 3. Apply the three verification passes, per section

For each section in the map, in order:

**Pass A — Existence + liveness.**

- Every file path the section references: does it exist in the repo?
- Every command the section prescribes: syntactically valid for the project's tooling?
- Every URL or external reference: reachable (where you can check)?

**Pass B — Assumption audit.**

- Extract every stated assumption ("the API supports pagination", "tests live in `__tests__/`", "Postgres 14 is available").
- Check each against `CONTEXT.md`, `package.json`, README, code, or ADRs.
- Ungrounded assumption → flag as `BLOCK`, decide whether it warrants an inline grill (see Grilling below).

**Pass C — Coding-principles pass.**

- Apply KISS / DRY / SOLID / YAGNI to the *design choices* in the section (test pyramid, rollback strategy, sequencing, abstraction shape).
- Tag findings with principle names (`KISS-violation`, `YAGNI`, `DRY-opportunity`, etc.) so the changelog is scannable.
- Skip if the section doesn't make design choices (e.g. pure metadata).

**Pass D (only with `--deep`) — Adversarial red-team.**

- Try to break the plan: missing edge cases in the test plan, rollback that doesn't undo the change, E2E that doesn't exercise the user-visible behaviour, race conditions, partial-failure modes.

### 4. Decide per section: `Improved` / `Verified (no change)` / `New gap`

After the three passes, every section lands in exactly one bucket:

- **`Improved`** — at least one edit was made. The changelog entry records the diff and the verdict tag.
- **`Verified (no change)`** — every claim was verified, no edits needed, and the section is sound. The changelog entry records *what was checked* and *why it's sound*. This is not silence — it's an explicit positive claim.
- **`New gap`** — the section is missing entirely, or a load-bearing claim can't be grounded. Recorded with the missing piece described.

See [CHANGELOG-TEMPLATE.md](CHANGELOG-TEMPLATE.md) for the exact field shape.

### 5. Edit the plan inline

Only the sections in `Improved` get edited. Everything else is untouched. Make edits surgical — preserve the dumber model's voice and structure where you can. You're a polish pass, not a rewrite.

The new content goes into `<plan-path>`. The original is in `<plan-path>.original.md`.

### 6. Emit the changelog

Write the changelog to `<plan-path-without-md>_CHANGELOG.md` (sibling of the plan). Three top-level sections matching the three buckets. Per-entry verdict tag (`PASS / WARN / REVISE / BLOCK`) + the orthogonal `MISSING-USER-INPUT` flag where applicable.

See [CHANGELOG-TEMPLATE.md](CHANGELOG-TEMPLATE.md).

### 7. Inline grilling (when triggered)

Grilling fires only when:

- A factual claim can't be verified from the codebase or docs.
- A blocking assumption makes a downstream decision impossible without a value.

Grilling rules:

- **One question at a time.** Wait for the answer before continuing. Use the existing `question` tool if available.
- **Budget: ~5 questions per review.** Single budget across the whole review, not per section. If exhausted, mark remaining gaps as `ASSUMED: <value>` in the changelog and continue.
- **Scope: factual claims only.** Value judgements (`should we use Redis or Memcached?`) are made by the reviewer with explicit `ASSUMED:` annotations — don't grill on these.
- **Record inline.** The user's answer goes into the relevant `New gap` or `Improved` entry, formatted as a `> Q: … A: …` block, so the changelog is self-contained.

If a gap is so foundational that it deserves a permanent `CONTEXT.md` entry or an ADR, **bail the polish and escalate to `grill-with-docs`**. The bailing signal is `REJECT-PLAN` (see Escape hatch below) plus the message: "this gap is too foundational for a polish pass — it needs grill-with-docs."

### 8. Escape hatch: `REJECT-PLAN`

If the plan's overall approach is fundamentally wrong (not just sections within it):

- **Do not polish.** Don't make a wrong plan prettier.
- **Emit `REJECT-PLAN` at the top of the changelog** with a one-paragraph reason.
- **Do not edit the plan file.** Leave the original intact.
- **Suggest:** `grill-with-docs` (from scratch) or `to-prd` (to reframe the problem).

The plan stays as-is; the user is told to start over with the right skill.

### 9. Exit

The polish is complete when:

- Every section in the original is categorized into one of the three buckets.
- Every `BLOCK` is resolved by grilling or explicitly marked `ASSUMED:` in the changelog.

Then output a one-line summary:

```
Polished <N> sections, verified <M> unchanged, found <K> new gaps.
Changelog: <changelog-path>.
Suggested next: /domino <plan-path>   (or: /ai-execution <plan-path>)
```

## Verification mechanics — detail

Per-section verification is the bulk of the work. See [VERIFICATION-CHECKLIST.md](VERIFICATION-CHECKLIST.md) for what to look for in each section type (`Context Snapshot`, `Files to Read`, `Implementation Steps`, `Test Plan`, `E2E Verification`, `Risks and Mitigations`, `Rollback Procedure`, `Execution Log`).

## Changelog shape

See [CHANGELOG-TEMPLATE.md](CHANGELOG-TEMPLATE.md) for the template. Three buckets (`Improved` / `Verified (no change)` / `New gaps`) with per-entry verdict tags.

## What polish-plan is NOT

- **Not a verdict.** No `APPROVE / REVISE / REJECT` on the whole plan. Improvement is the deliverable.
- **Not a rewriter.** Don't restructure sections that already work. The dumber model did the grunt; honour it.
- **Not grill-with-docs.** `grill-with-docs` interviews you from scratch. `polish-plan` works an existing artifact. They escalate *to* each other (when a gap is too foundational), not overlap.
- **Not a code reviewer.** `coding-principles` reviews *code*. `polish-plan` applies coding-principles' heuristics *to the plan's design choices* inline. It does not invoke `coding-principles` as a sub-skill on the plan itself.

## Output discipline

- **Token economy.** Read the plan once. Build a section map. Don't re-read mapped sections. Per-section work uses the map, not the source.
- **Original preserved.** `<plan-path>.original.md` is the rollback path. Don't lose it.
- **Changelog is the audit trail.** Every change has a reason. Every unchanged section has a reason. Every new gap has a description.
- **Honest about limits.** If you couldn't verify something, say so in the changelog. Don't smuggle assumptions in silently.

## Related skills

- `execution-plan` — produces the kind of plan `polish-plan` consumes.
- `grill-with-docs` — the escape hatch when a plan is too broken to polish.
- `coding-principles` — heuristics `polish-plan` applies inline to the plan text.
- `domino` — interactive step-by-step execution; the natural next step after polish.
- `ai-execution` — delegated execution; the alternative next step.