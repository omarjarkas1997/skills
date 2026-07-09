---
name: execution-plan
description: Universal execution planning framework for AI agents. Use whenever you need to plan work for implementation — creates comprehensive, handoff-ready plans that any agent can execute.
---

# Execution Planning Framework

Use this skill when you need to plan work for an AI agent to implement. It ensures plans are comprehensive, generic, and handoff-ready.

## Resource

- [PLANNING_FRAMEWORK.md](./PLANNING_FRAMEWORK.md) — The complete planning framework

## When to Use

- Starting a new feature, bug fix, or task
- Handing off work to another AI agent
- Planning infrastructure deployments
- Any task requiring structured execution

## Key Principles

1. **Never assume. Always discover.** — Every codebase is different
2. **Document as you discover.** — Record findings for the next agent
3. **Be explicit.** — Exact commands, not "run tests"
4. **Make it reproducible.** — Fresh agents can execute without questions
5. **Handle failure.** — Include rollback and troubleshooting

## Workflow

1. **Discover** — Explore environment, codebase, tests, patterns
2. **Plan** — Create `docs/AI_EXECUTION_PLAN_<TASK>.md`
3. **Validate** — Check plan against the Final Checklist
4. **Execute** — Follow the plan step by step
5. **Log** — Update execution log with what was done
6. **Review** — Verify success against plan objectives

## Output

A comprehensive execution plan in `docs/AI_EXECUTION_PLAN_<TASK>.md` containing:
- Context Snapshot (auto-discovered environment)
- Files to Read (with justification)
- Implementation Steps (exact changes)
- Test Plan (by layer)
- E2E Verification
- Risks and Mitigations
- Rollback Procedure
- Execution Log (living document)
