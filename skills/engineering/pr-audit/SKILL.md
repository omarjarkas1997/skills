---
name: pr-audit
description: Audit open GitHub pull requests one at a time and recommend keep, defer, or discard. Reads PR metadata, diff, CI status, and repo docs via `gh`; stores verdicts in a local Markdown state file. Use when reviewing a backlog of open PRs, deciding whether stale PRs are worth keeping, or cleaning up a repo's pull requests.
---

# PR Audit

Audit open pull requests incrementally and recommend whether each one is worth keeping.

## Prerequisites

- `gh` (GitHub CLI) >= 2.30, authenticated and able to read the target repo
- Run inside a git repo with a GitHub remote

## Quick start

```
/pr-audit
```

1. Lists open PRs for the current repo.
2. Picks the next unanalyzed PR.
3. Fetches metadata, diff, CI status, and any task lists.
4. Reads `CONTEXT.md`, `CLAUDE.md`, `AGENTS.md`, and `docs/adr/` if present.
5. Recommends `keep`, `defer`, or `discard` with a short rationale.
6. Records the verdict in `.scratch/pr-audit-<repo>.md`.
7. Asks whether to continue to the next PR, re-analyze this one, or stop.

## Verdicts

- **keep** — the PR adds real value, is not duplicated, and can realistically be merged or revived.
- **defer** — the PR has value but is blocked (merge conflict, missing context, incomplete tasks) and needs action before a final decision.
- **discard** — the PR is stale, duplicated, obsolete, or adds no meaningful value.

## Signals analyzed

| Signal | How it influences the verdict |
|--------|------------------------------|
| Functionality | Does the diff implement a real, coherent change? |
| Duplication | Title/branch similarity and overlapping file paths with other open PRs; flagged as "possible duplicate" for you to confirm. |
| Staleness | Last activity date and how far the base branch has drifted. |
| Merge conflicts | `mergeStateStatus` from `gh pr view`; `blocked`/`dirty` pushes toward `defer` or `discard`. |
| CI status | Latest check conclusion; failing checks push toward `defer` unless the change is clearly salvageable. |
| Linked context | Issue/ADR/spec references in the body or commits; missing context pushes toward `defer`. |
| Task-list completion | Incomplete tasks push toward `defer` but do not auto-defer. |
| Draft status | Drafts are flagged; not auto-deferred. |

## State file

Verdicts are recorded in:

```
.scratch/pr-audit-<repo>.md
```

Format:

```markdown
# PR Audit: owner/repo

## PR #123 — feat(cli): add widget

- **Verdict:** keep
- **Analyzed:** 2026-06-18
- **Rationale:** Implements a clean, isolated feature. No duplicates. CI passing. Base branch only 2 commits ahead.

## PR #124 — old experiment

- **Verdict:** discard
- **Analyzed:** 2026-06-18
- **Rationale:** No activity in 60 days. Base branch is 120 commits ahead. Merge conflict. Superseded by #123 (overlapping files: src/widget.go).
```

## Commands

- `/pr-audit` — analyze the next unanalyzed PR.
- `/pr-audit #42` — analyze or re-analyze PR #42.
- `/pr-audit summary` — print counts and flagged PRs from the state file.

## Process

1. **Validate environment.** Fail fast if `gh` is missing or unauthenticated. Derive `owner/repo` from the current git remote.
2. **Load state.** Read `.scratch/pr-audit-<repo>.md`. Create it if missing.
3. **Select PR.** List open PRs with `gh pr list --json number`. Pick the next one not in state, or the one the user specified. For `/pr-audit #42`, always re-analyze.
4. **Fetch data.** Use `gh pr view`, `gh pr diff`, `gh run list`/`gh pr checks`, and `gh api repos/{owner}/{repo}/compare/{base}...{head}` as needed.
5. **Detect duplicates.** Compare title tokens and changed file paths against other open PRs. Never auto-discard; surface as a signal.
6. **Read repo docs.** If `CONTEXT.md`, `CLAUDE.md`, `AGENTS.md`, or `docs/adr/` exist, read them to judge whether the PR aligns with documented decisions.
7. **Formulate verdict.** Weigh all signals and pick `keep`, `defer`, or `discard`.
8. **Report.** Show one-line verdict and 2–4 sentence rationale.
9. **Record.** Append or update the entry in the state file with a timestamp.
10. **Prompt user.** Ask: continue, re-analyze, or stop.

## Rules

- This skill is **read-only** against GitHub. It never closes, merges, or comments on PRs.
- Duplicate detection is **heuristic**. Present it as "possible duplicate" and let the user confirm.
- Never auto-`defer` a draft or incomplete-task PR; treat them as weighted signals.
- Keep rationale under 100 words per PR.
- If no open PRs remain, print a short completion message and offer the summary command.
