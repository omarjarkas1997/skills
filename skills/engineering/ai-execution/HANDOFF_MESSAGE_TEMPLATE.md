# Handoff Message Template

## Purpose

This template is for the **Planner Agent** (you) to hand off a plan to an **Executor Agent**.

Copy this template, fill in the blanks, and send it to the executor.

---

## Template

```
# AI Agent Execution Task

## Role
You are the **Executor Agent**. Implement the attached plan and return an execution logbook.

## Context
[One paragraph about what this project is and why we're doing this task]

## Your Task
Execute the plan in the attached file: [filename]

## Rules
1. Read the ENTIRE plan before starting
2. Follow the plan exactly — document any deviations
3. Record everything — every command, every output
4. Produce a complete execution logbook using the template
5. Do not interpret results or make recommendations
6. Do not start tasks not in the plan
7. If stuck after 3 attempts, document the blocker and stop

## What to Return
1. Execution logbook (markdown)
2. Any output files referenced in the logbook
3. [Any specific artifacts the planner expects]

## Security
- NEVER expose secrets in output
- NEVER commit secrets to git
- Clean up temp credentials after use

## Questions?
If the plan is unclear:
1. Document what you assumed
2. Proceed with your best interpretation
3. Note the ambiguity in the logbook

---

ATTACHED: [Plan filename]
```

---

## Example Filled Template

```
# AI Agent Execution Task

## Role
You are the **Executor Agent**. Implement the attached plan and return an execution logbook.

## Context
This is a homelab Kubernetes cluster running k3s over Tailscale. We have 3 Linux nodes: a control plane (xps-workstation-i9) and two workers (alienware-i7-970m, pop-os). The cluster is operational with kubectl configured on the control plane.

## Your Task
Execute the plan in the attached file: AI_EXECUTION_PLAN_HEADLAMP_TAILSCALE.md

## Rules
1. Read the ENTIRE plan before starting
2. Follow the plan exactly — document any deviations
3. Record everything — every command, every output
4. Produce a complete execution logbook using the template in docs/EXECUTION_LOGBOOK_TEMPLATE.md
5. Do not interpret results or make recommendations
6. Do not start tasks not in the plan
7. If stuck after 3 attempts, document the blocker and stop

## What to Return
1. Execution logbook (markdown)
2. Any output files referenced in the logbook
3. Generated docs/ACCESS.md file

## Security
- NEVER expose secrets in output
- NEVER commit secrets to git
- Clean up temp credentials after use

## Questions?
If the plan is unclear:
1. Document what you assumed
2. Proceed with your best interpretation
3. Note the ambiguity in the logbook

---

ATTACHED: AI_EXECUTION_PLAN_HEADLAMP_TAILSCALE.md
```

---

## Quick Reference

### For the Planner (You)

**Before sending:**
- [ ] Plan is complete and follows PROMPT_PLAN.md
- [ ] All files referenced in plan exist
- [ ] Prerequisites are documented
- [ ] Rollback procedure is documented
- [ ] EXECUTOR_PROMPT.md is attached or referenced

**After receiving logbook:**
- [ ] Run through PLANNER_REVIEW_CHECKLIST.md
- [ ] Determine if execution was successful
- [ ] Report results to user

### For the Executor (The New Agent)

**Before executing:**
- [ ] Read EXECUTOR_PROMPT.md
- [ ] Read the plan completely
- [ ] Read EXECUTION_LOGBOOK_TEMPLATE.md
- [ ] Understand the environment from Context Snapshot

**During execution:**
- [ ] Follow plan step by step
- [ ] Document everything
- [ ] Use exact commands

**After execution:**
- [ ] Fill out logbook completely
- [ ] Include all outputs
- [ ] Sign off with status
