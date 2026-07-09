---
name: grill-to-plan
description: Grill a rough plan or task with domain-aware questions, then synthesize and save a formal AI_EXECUTION_PLAN_<TASK>.md following the execution-plan framework.
---

# grill-to-plan

Take a rough plan, goal, or existing plan draft; interview the user relentlessly using `grill-with-docs` semantics; then emit a handoff-ready `docs/AI_EXECUTION_PLAN_<TASK>.md`.

## When to use

- You have a fuzzy idea and need a structured plan.
- You have a rough plan and want to stress-test it before execution.
- You want another agent (opencode, Claude, pi) to be able to pick up the plan and execute it without asking questions.

## When not to use

- The task is trivial (< 3 steps).
- The plan already exists and is complete; use `execution-plan` or just execute.
- You need an answer now and cannot tolerate a multi-round interview.

## Invocation

```text
/grill-to-plan [optional existing plan path or task description]
```

If an existing plan path is provided, the skill enters **refine mode**.
If only a task description is provided, the skill enters **create mode**.

## Workflow

### 1. Discover

Read project conventions if they exist (missing files are skipped):

- `CONTEXT.md` / `CONTEXT-MAP.md`
- `CLAUDE.md` / `AGENTS.md`
- `docs/adr/`
- Existing `docs/AI_EXECUTION_PLAN_*.md` for style examples
- `Makefile`, `package.json`, `Cargo.toml`, etc. for build/test commands

If an existing plan path was supplied, read it.

### 2. Frame

- Summarize the task back to the user.
- Propose a default plan filename slug: `docs/AI_EXECUTION_PLAN_<SLUG>.md`.
- Ask the user to confirm the slug or provide a different one.

### 3. Grill

Ask one question at a time. Each question should resolve a branch of the design tree. Provide a recommended answer.

Continue until either:

- All required sections of the execution-plan template can be filled without guessing, or
- The user explicitly says "enough", "proceed", or "write the plan".

Typical question branches:

- Scope and boundaries
- Timing and sequencing
- Executor (this agent, another agent, or the user)
- Risk tolerance and rollback appetite
- Interface/tool choices
- Verification criteria
- What to do with artifacts (commit, delete, leave untracked)

### 4. Synthesize

Write the formal plan following the `execution-plan` framework:

- Context Snapshot
- Files to Read / Modify (with justification)
- Implementation Steps (exact changes where known)
- Test Plan (by layer)
- E2E Verification
- Risks and Mitigations
- Rollback Procedure
- Execution Log (living document, empty initially)

### 5. Save

Write the plan to the confirmed path.

## Output

A single markdown file at `docs/AI_EXECUTION_PLAN_<SLUG>.md`.

## Stop condition

Stop grilling when the plan is executable by a fresh agent without further questions.
