# grill-to-plan

Grill a rough plan or task with domain-aware questions, then synthesize a formal `docs/AI_EXECUTION_PLAN_<TASK>.md`.

## Usage

```text
/grill-to-plan [optional existing plan path or task description]
```

## What it does

1. Discovers project conventions and existing plans.
2. Frames the task and proposes a filename slug.
3. Interviews you one question at a time until the plan is fully resolved.
4. Writes a handoff-ready execution plan.

## Dependencies

- `execution-plan` framework for the output format.
- `grill-with-docs` semantics for the interview style.

## Install

Run `./install.sh` from this directory to symlink the skill into `.skills/grill-to-plan/` for opencode/Claude/pi discovery.
