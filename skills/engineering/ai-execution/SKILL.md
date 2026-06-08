---
name: ai-execution
description: Hand off a detailed plan to an executor agent and receive a structured logbook for planner review. Use when you want to delegate implementation to another agent while maintaining oversight.
---

# AI Execution Handoff

Use this skill when you have a comprehensive plan (`docs/AI_EXECUTION_PLAN_<TASK>.md`) and want another AI agent to execute it.

## Resources

- [EXECUTOR_PROMPT.md](./EXECUTOR_PROMPT.md) — Instructions for the executor agent
- [EXECUTION_LOGBOOK_TEMPLATE.md](./EXECUTION_LOGBOOK_TEMPLATE.md) — Format the executor must fill out
- [PLANNER_REVIEW_CHECKLIST.md](./PLANNER_REVIEW_CHECKLIST.md) — Checklist for reviewing the returned logbook
- [HANDOFF_MESSAGE_TEMPLATE.md](./HANDOFF_MESSAGE_TEMPLATE.md) — Template for the handoff message

## Workflow

1. **Planner creates plan** following `PROMPT_PLAN.md`
2. **Planner sends handoff message** using `HANDOFF_MESSAGE_TEMPLATE.md`
3. **Executor implements plan** using `EXECUTOR_PROMPT.md`
4. **Executor returns logbook** using `EXECUTION_LOGBOOK_TEMPLATE.md`
5. **Planner reviews logbook** using `PLANNER_REVIEW_CHECKLIST.md`
6. **Planner reports success/failure** to the user

## When to Use

- You have a detailed plan but want a fresh agent to execute it
- The implementation is long-running or requires many steps
- You want a structured audit trail of what was done
- You want another agent to validate the execution independently
- The task is infrastructure-heavy and benefits from fresh context

## When NOT to Use

- Simple one-step tasks (overhead too high)
- Tasks requiring continuous human feedback during execution
- Tasks where the plan is incomplete or ambiguous
- Emergency fixes where speed matters more than auditability
