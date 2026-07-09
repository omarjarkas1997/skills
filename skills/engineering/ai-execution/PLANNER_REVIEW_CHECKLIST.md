# Planner Review Checklist

## Purpose

This checklist is for the **Planner Agent** to review an execution logbook returned by an Executor Agent. Use it to verify the execution was 100% successful or identify what needs fixing.

## How to Use

1. Read the execution logbook from top to bottom
2. Check each item below
3. Mark [PASS], [FAIL], or [N/A] for each
4. Document any issues found
5. Make a final determination

---

## Section 1: Completeness Check

### Plan Coverage
- [ ] **Every step in the plan has a log entry**
  - [PASS] All steps documented
  - [FAIL] Missing steps: [list them]

- [ ] **No steps are silently skipped**
  - [PASS] All steps accounted for
  - [FAIL] Steps skipped without documentation: [list them]

- [ ] **Deviations are documented with reasons**
  - [PASS] All changes from plan explained
  - [FAIL] Undocumented deviations: [list them]

### Environment Documentation
- [ ] **Environment section is complete**
  - [PASS] Timestamp, directory, user, platform recorded
  - [FAIL] Missing: [list missing fields]

- [ ] **Pre-execution checks were performed**
  - [PASS] All checks listed
  - [FAIL] Missing checks: [list them]

---

## Section 2: Execution Quality

### Commands
- [ ] **Commands are exact and copy-pasteable**
  - [PASS] Exact commands shown
  - [FAIL] Vague commands: [list them]

- [ ] **Command outputs are captured**
  - [PASS] Outputs shown for key commands
  - [FAIL] Missing outputs: [list which commands]

- [ ] **Error messages are complete**
  - [PASS] Full error messages with context
  - [FAIL] Truncated or missing errors: [list them]

### Verification
- [ ] **Each step has verification**
  - [PASS] Every completed step verified
  - [FAIL] Steps without verification: [list them]

- [ ] **Verification actually checks the right thing**
  - [PASS] Verification validates the step objective
  - [FAIL] Weak verification: [list them]

---

## Section 3: Success Verification

### Objectives
- [ ] **Final state matches plan objectives**
  - [PASS] All objectives achieved
  - [PARTIAL] Some objectives achieved: [list gaps]
  - [FAIL] Objectives not achieved: [list them]

### Tests
- [ ] **Unit tests passed (if applicable)**
  - [PASS] All passed
  - [FAIL] Failures: [list them]
  - [N/A] No unit tests in plan

- [ ] **Integration tests passed (if applicable)**
  - [PASS] All passed
  - [FAIL] Failures: [list them]
  - [N/A] No integration tests in plan

- [ ] **E2E verification passed (if applicable)**
  - [PASS] Verified end-to-end
  - [FAIL] E2E failed: [describe]
  - [N/A] No E2E in plan

### System State
- [ ] **No orphaned processes**
  - [PASS] Clean process list
  - [FAIL] Unexpected processes running: [list them]

- [ ] **No temporary files left**
  - [PASS] Temp files cleaned up
  - [FAIL] Temp files remaining: [list locations]

- [ ] **No configuration drift**
  - [PASS] Only planned changes made
  - [FAIL] Unexpected changes: [describe]

---

## Section 4: Issue Handling

### Issues Table
- [ ] **All issues documented in Issues table**
  - [PASS] All problems listed
  - [FAIL] Undocumented issues: [describe]

- [ ] **Issue severity is accurate**
  - [PASS] Severity matches impact
  - [FAIL] Misclassified: [list them]

- [ ] **Resolution status is clear**
  - [PASS] Every issue has status
  - [FAIL] Unclear status: [list them]

### Blockers
- [ ] **Critical blockers were handled appropriately**
  - [PASS] Stopped execution or found workaround
  - [FAIL] Ignored critical blocker: [describe]

---

## Section 5: Security & Secrets

- [ ] **No secrets exposed in logbook**
  - [PASS] Secrets referenced but not shown
  - [FAIL] Secrets visible: [redact immediately]

- [ ] **Credentials stored securely**
  - [PASS] In env vars, secret files, or vault
  - [FAIL] Credentials in plain text: [describe]

- [ ] **Temporary access cleaned up**
  - [PASS] No lingering temporary credentials
  - [FAIL] Temp credentials still active: [describe]

---

## Section 6: Handoff Readiness

- [ ] **Next agent could continue from final state**
  - [PASS] Clear final state documented
  - [FAIL] Ambiguous state: [describe]

- [ ] **Rollback commands provided (if applicable)**
  - [PASS] Rollback documented
  - [FAIL] Missing rollback: [describe risk]

- [ ] **Artifacts are accessible**
  - [PASS] All files/URLs listed with locations
  - [FAIL] Can't locate artifacts: [list missing]

---

## Section 7: Executor Quality

- [ ] **Executor followed the plan**
  - [PASS] Executed as written
  - [FAIL] Deviated without good reason: [list]

- [ ] **Executor didn't add scope**
  - [PASS] Only did what was planned
  - [FAIL] Added unplanned work: [describe]

- [ ] **Executor documented assumptions**
  - [PASS] Assumptions explicit
  - [FAIL] Hidden assumptions: [list]

---

## Final Determination

### Overall Status

**Select one:**

- [ ] **APPROVED** — Execution is 100% complete and successful
  - All steps completed
  - All tests passed
  - No critical issues
  - Clean handoff

- [ ] **APPROVED_WITH_NOTES** — Execution successful with minor issues
  - Core objectives achieved
  - Minor issues documented
  - No action required or issues are cosmetic

- [ ] **NEEDS_FIX** — Execution partially successful, requires follow-up
  - Some objectives achieved
  - Issues need resolution
  - Specific fixes required: [list them]

- [ ] **REJECTED** — Execution failed, rollback required
  - Critical objectives not achieved
  - System in bad state
  - Rollback recommended: [why]

### Issues Summary

| # | Issue | Severity | Action Required | Owner |
|---|-------|----------|----------------|-------|
| 1 | [description] | [critical/high/medium/low] | [what needs to happen] | [who does it] |

### Required Fixes

1. [Fix description and how to verify]
2. [Fix description and how to verify]

### Next Steps

- [ ] [What happens next]
- [ ] [Who does it]
- [ ] [When it should be done]

### Planner Notes

[Any observations about the execution or executor performance]

---

## Sign-off

**Planner Agent:** [your identifier]
**Reviewed at:** [ISO 8601 timestamp]
**Overall Status:** [APPROVED / APPROVED_WITH_NOTES / NEEDS_FIX / REJECTED]

**Return to user:** [YES / NO — does the user need to see this review?]
