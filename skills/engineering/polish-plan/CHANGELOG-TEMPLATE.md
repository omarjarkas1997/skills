# Changelog Template

The reviewer fills in this template. Replace every `{...}` placeholder. Delete the explanatory comments before writing.

```md
# Polish Changelog: {plan-path}

**Reviewed:** {ISO date}
**Reviewer:** {claude model + skill version, or "polish-plan v0.1"}
**Plan path:** {plan-path}
**Original:** {plan-path}.original.md

## Summary

- **{N} sections improved**
- **{M} sections verified (no change)**
- **{K} new gaps**
- **{B} unresolved BLOCKs** (marked `ASSUMED:` after grill budget exhausted — should be 0 in a healthy polish)
- **{G} grill questions fired** (of ~5 budget)

---

## REJECT-PLAN  <!-- Delete this section unless the plan's overall approach is wrong -->

The plan's overall approach is fundamentally wrong: {one paragraph explaining why a polish pass can't fix it}. Do NOT execute this plan. Suggested next: `/grill-with-docs` from scratch, or `/to-prd` to reframe.

---

## Improved

Each entry: section name, verdict tag, principle tags if any, before/after diff or summary, reason for the change.

### {Section name}  <!-- e.g. "Implementation Steps" -->

- **Verdict:** `REVISE`  <!-- PASS / WARN / REVISE / BLOCK -->
- **MISSING-USER-INPUT:** No  <!-- Yes / No; if Yes, the user's answer follows -->
- **Principles:** KISS, YAGNI  <!-- principle tags if any -->
- **What changed:** {one-sentence summary of the edit}
- **Why:** {one-sentence reason — the verification that triggered it}
- **Diff (optional):**
  ```diff
  - {old line}
  + {new line}
  ```

> Q: {grill question, if any}
> A: {user's answer}

<!-- Repeat the entry block for each Improved section -->

---

## Verified (no change)

Each entry: section name, what was checked, why it was left alone. **No section may be silently omitted from this list** — every checked section lands here.

### {Section name}  <!-- e.g. "Files to Read" -->

- **Verdict:** `PASS`
- **MISSING-USER-INPUT:** No
- **Checked:**
  - {claim 1 — verified by reading /path/to/file:line}
  - {claim 2 — verified by checking package.json field X}
  - {claim 3 — N/A; section is metadata}
- **Why no change:** {one sentence — the section's design is sound, or already follows coding-principles, or has nothing to verify}

<!-- Repeat the entry block for each Verified section -->

---

## New gaps

Each entry: missing or unfixable piece, where it should live in the plan, grill trace if any.

### {Gap name}  <!-- e.g. "Rollback Procedure missing" -->

- **Verdict:** `BLOCK`
- **MISSING-USER-INPUT:** Yes
- **Should live in:** {plan section name}
- **What's missing:** {description}
- **Resolution:**
  - Resolved by grilling: see Q/A below.
  - OR marked `ASSUMED:` after grill budget exhausted.

> Q: {grill question}
> A: {user's answer}

**`ASSUMED:`** {value the reviewer proceeded with, if any}

<!-- Repeat the entry block for each New gap -->

---

## Notes

- {Anything else worth recording — context the user should know about the polish}
```

## Field reference

| Field | Required | Notes |
|---|---|---|
| Section name | yes | Must match a section in the original plan (or note if it's a new section being added) |
| Verdict | yes | `PASS` / `WARN` / `REVISE` / `BLOCK` |
| MISSING-USER-INPUT | yes | `Yes` / `No` — orthogonal to verdict |
| Principles | if any | `KISS` / `DRY` / `SOLID` / `YAGNI` (or principle names from your project's vocabulary) |
| What changed | yes (Improved only) | One sentence |
| Why | yes | One sentence — the verification or principle that triggered the change |
| Diff | optional | Only when the change is small enough to inline |
| Checked | yes (Verified only) | Bulleted list of claims and how each was verified |
| Why no change | yes (Verified only) | One sentence — the section was already sound |
| Resolution | yes (New gaps only) | Either a Q/A block, an `ASSUMED:` annotation, or both |

## What this template enforces

- **Exhaustive coverage.** Every section in the original appears in exactly one bucket. No silent omissions.
- **Audit trail.** Every change has a reason. Every unchanged section has a reason. Every gap has a description.
- **Trust by arithmetic.** The user can count `Improved + Verified + New gaps = total sections in original` and know nothing was skipped.
- **Grill trace inline.** Q/A blocks are embedded in the relevant entry, so the changelog is self-contained — no "see conversation log" cross-references.