# Execution Logbook Template

# Execution Logbook

## Task
[Copy the exact objective from the plan]

## Environment
- **Started at:** [ISO 8601 timestamp]
- **Working directory:** [pwd output]
- **User:** [whoami]
- **Platform:** [OS name and version]
- **Hostname:** [hostname]
- **Shell:** [$SHELL]
- **Plan file location:** [path to AI_EXECUTION_PLAN file]

## Pre-Execution Checks
- [ ] Plan file exists and is readable
- [ ] All prerequisites from plan Phase 1 are available
- [ ] No conflicting processes running
- [ ] Sufficient disk space: [df -h /]
- [ ] Sufficient memory: [free -h]
- [ ] Network connectivity: [ping to required hosts]
- [ ] Backups created (if applicable): [how/where]

**Pre-execution notes:**
[Any observations about the environment before starting]

---

## Execution Steps

### Step 1: [Name from plan]
**Planned action:** [What the plan said to do]

**Status:** [COMPLETED / FAILED / SKIPPED]

**What I did:**
```bash
[exact command 1]
[exact command 2]
```

**Output:**
```
[full command output]
```

**Issues encountered:**
[None / Description of problem]

**Workarounds applied:**
[None / What you tried and what worked]

**Verification:**
```bash
[command to verify step worked]
```
```
[verification output]
```

**Notes:**
[Any additional observations]

---

### Step 2: [Name from plan]
[Same structure as Step 1]

---

[Continue for all steps...]

---

## Final State

### What Was Completed
- [ ] [Item 1 from plan — checked if done]
- [ ] [Item 2 from plan]
- [ ] [Additional items completed]

### What Was Not Completed
- [ ] [Item not completed] — Reason: [why]
- [ ] [Item not completed] — Reason: [why]

### Current System State
**Running processes:**
```
[ps aux | grep relevant or docker ps or kubectl get pods]
```

**Modified files:**
```bash
git status
# or find . -newer /tmp/start_timestamp
```

**New files created:**
- `path/to/file` — [purpose]
- `path/to/file` — [purpose]

**Configuration changes:**
- [What config files changed and how]

**Environment variables set:**
```
[env | grep relevant]
```

---

## Test Results

### Unit Tests
- **Command run:** [exact command]
- **Result:** [PASS / FAIL / N/A]
- **Output summary:**
```
[first 50 lines or relevant failures]
```
- **Test count:** [X passed, Y failed, Z skipped]

### Integration Tests
- **Command run:** [exact command]
- **Result:** [PASS / FAIL / N/A]
- **Output summary:**
```
[first 50 lines or relevant failures]
```

### E2E Verification
- **Command run:** [exact command]
- **Result:** [PASS / FAIL / N/A]
- **Evidence:**
```
[curl output, screenshot description, etc.]
```

---

## Issues & Blockers

| # | Issue Description | Severity | Attempted Resolution | Status |
|---|-------------------|----------|---------------------|--------|
| 1 | [What happened] | [critical/high/medium/low] | [What you tried] | [open/resolved/workaround] |
| 2 | [What happened] | [critical/high/medium/low] | [What you tried] | [open/resolved/workaround] |

---

## Deviations from Plan

| Step # | Planned Action | Actual Action | Reason for Deviation |
|--------|---------------|---------------|---------------------|
| [step] | [what plan said] | [what you did] | [why you changed] |
| [step] | [what plan said] | [what you did] | [why you changed] |

---

## Artifacts Produced

- **Files:**
  - `path/to/file` — [description]
  - `path/to/file` — [description]

- **URLs:**
  - [service URL] — [what it is]

- **Configuration:**
  - [what config was applied]

- **Secrets/Credentials:**
  - [where stored, NEVER the actual values]

---

## Rollback Information

If this deployment needs to be undone, run these commands in order:

```bash
# Step 1: [description]
[command]

# Step 2: [description]
[command]

# Step 3: Verify rollback
[verification command]
```

**Rollback tested:** [YES / NO]

---

## Handoff Notes for Planner

**What the planner should know when reviewing this logbook:**

1. [Key observation 1]
2. [Key observation 2]
3. [Any surprises or unexpected behavior]

**Questions for the planner:**
- [Any clarifications needed]
- [Any decisions the planner should make]

**Recommendations for next steps:**
[None — executor doesn't make recommendations, but can note what remains from the plan]

---

## Performance Metrics

- **Total execution time:** [HH:MM:SS]
- **Steps completed:** [X/Y]
- **Steps failed:** [Z]
- **Steps skipped:** [W]
- **Retry attempts:** [N]

---

## Sign-off

**Executor Agent:** [your identifier or "AI Executor"]
**Completed at:** [ISO 8601 timestamp]
**Overall Status:** [SUCCESS / PARTIAL_SUCCESS / FAILED]

**Status definitions:**
- **SUCCESS:** All steps completed, all tests passed, no issues
- **PARTIAL_SUCCESS:** Some steps failed or skipped, but core objective achieved
- **FAILED:** Critical steps failed, objective not achieved, rollback may be needed

**Planner review required:** [YES / NO]
**Reason for review:** [why the planner needs to look at this]
