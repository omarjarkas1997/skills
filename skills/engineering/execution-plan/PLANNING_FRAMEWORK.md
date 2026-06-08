# AI Execution Planning Framework

You are planning work for an AI coding agent. The agent will execute with only **"Proceed"** — your plan must be complete enough for that.

## Core Principle

**Never assume. Always discover.**

Every codebase, infrastructure, and environment is different. Your plan must be a **discovery framework** that any agent can use to understand any codebase, not a template for a specific one.

---

## Phase 1: Environment Discovery (Mandatory)

Before writing any code or planning implementation, you MUST answer these questions:

### 1.1 How Do I Access This Environment?
- Am I running on the target machine or accessing it remotely?
- If remote: SSH? API? Container exec? Cloud console?
- What credentials are needed? (env vars, files, key vaults, manual input)
- Where are credentials stored? (NEVER expose secrets in output)

### 1.2 What's Already Here?
- What's the repository structure? (`ls -la` at root)
- What's the technology stack? (build files, package managers, runtime)
- What's currently deployed? (processes, containers, services)
- What's the current state? (git status, running services, database state)

### 1.3 What Do I Need?
- What tools are installed? (compilers, interpreters, package managers)
- What tools are missing? (can I install them? do I need human help?)
- What secrets/configs do I need? (API keys, database URLs, certificates)
- What are the prerequisites for this task?

### 1.4 Document Discoveries
Create a **Context Snapshot** section in your execution plan:
```
## Context Snapshot (Auto-Discovered)

### Environment
- Access: [how you reached the environment]
- Working Directory: [pwd]
- User: [whoami]
- Platform: [OS, arch]

### Repository
- Structure: [top-level dirs]
- Build System: [e.g., npm, make, cargo, poetry]
- Language(s): [detected from files]
- Git Status: [branch, clean/dirty]

### Infrastructure (if applicable)
- Runtime: [bare metal, docker, k8s, cloud]
- Services Running: [what's already deployed]
- Network: [relevant IPs, ports, DNS]

### Missing Prerequisites
- [list what needs to be installed or configured]
- [mark which require human action]
```

---

## Phase 2: Deep Exploration (Mandatory)

### 2.1 Read Everything You Touch
For every file the task mentions:
- Read the file
- Read its imports/dependencies
- Read its callers
- Read its tests
- Trace every value: where written, read, passed, stored

### 2.2 Find Established Patterns
Search for pattern documentation:
```bash
# Search for pattern files
find . -name "PATTERNS.md" -o -name "ARCHITECTURE.md" -o -name "STYLE.md"

# Search for code conventions
find . -name ".editorconfig" -o -name ".eslintrc" -o -name "pyproject.toml"
```

If patterns exist: **follow them exactly**.
If no patterns exist: **infer from existing code** and document your inferences.

### 2.3 Discover the Test Infrastructure
```bash
# Find test files
find . -name "*.test.*" -o -name "*_test.*" -o -name "test_*" -o -name "__tests__"

# Find test configuration
find . -name "jest.config.*" -o -name "pytest.ini" -o -name "go.mod"
```

Document what you find:
```
## Test Infrastructure (Discovered)

### Unit Tests
- Runner: [command]
- Location: [path pattern]
- Command: [exact command]
- Baseline: [how many tests exist now]

### Integration Tests
- [same structure]

### E2E Tests
- [same structure]

### Lint/Format/Type Check
- Command: [exact command]
```

---

## Phase 3: Plan Construction (Mandatory)

### 3.1 The Execution Plan File
**BEFORE implementation**, create:
```
docs/AI_EXECUTION_PLAN_<TASK>.md
```

This file must contain:

#### Section 1: Objective
What are we building/fixing/deploying?

#### Section 2: Context Snapshot
(From Phase 1 — copy discoveries here)

#### Section 3: Files to Read
List every file you will read, with justification:
- `path/to/file.ts` — main logic
- `path/to/file.test.ts` — existing tests
- `path/to/dependency.ts` — imported functions

#### Section 4: Implementation Steps
For each change:
1. **File:** `path/to/file`
2. **Change:** What exactly to modify
3. **Pattern Source:** Why this approach (link to pattern doc or existing code)
4. **Rationale:** Why this change is needed

#### Section 5: New Files
For each new file:
1. **Path:** Where it goes
2. **Contents:** Complete file contents
3. **Purpose:** Why it exists

#### Section 6: Test Plan
For every code change:
- Which test files to add/update
- Each test case (input, expected output, assertion)
- Why this test layer (unit/integration/E2E) is the right fit

#### Section 7: E2E Verification
How to verify the full solution works end-to-end:
- Commands to run
- Expected outputs
- How to check each component

#### Section 8: Migrations & Data Changes
- Breaking changes?
- Database migrations?
- Config/env additions?
- Rollback procedure?

#### Section 9: Risks
| Risk | Impact | Mitigation |
|------|--------|------------|
| [what could go wrong] | [high/medium/low] | [how to prevent/fix] |

#### Section 10: Execution Log (Starts Empty)
```
## Execution Log

### [TIMESTAMP]: Plan Created
- Discovered environment and documented context
- Identified test infrastructure
- Planned implementation steps

### [TIMESTAMP]: [Next Step]
[To be filled during execution]
```

---

## Phase 4: Execution Protocol

### 4.1 Before Implementation
1. **Create branch** (if using git): `git checkout -b feature/name`
2. **Write plan** — complete all sections above
3. **Validate plan** — can a fresh agent execute this without questions?
4. **Save plan** — commit the markdown file

### 4.2 During Implementation
1. **Execute one step at a time**
2. **Run tests after each change** — use the discovered test command
3. **Update execution log** — what you did, what changed, why
4. **Handle failures** — don't proceed until fixed
5. **Document workarounds** — if you deviate from the plan, explain why

### 4.3 After Implementation
1. **Run full test suite** — all discovered test layers
2. **Verify E2E** — run the verification plan
3. **Review changes** — `git diff` or equivalent
4. **Commit** — descriptive messages referencing the plan
5. **Create PR** — reference the execution plan markdown
6. **Clean up** — remove temp files, close branches

---

## Phase 5: Handoff Requirements

### 5.1 What Makes a Plan Handoff-Ready?
A fresh agent should be able to:
- ✅ Understand the environment from the Context Snapshot
- ✅ Know what commands to run (exact commands, not "run tests")
- ✅ Find all relevant files (explicit paths)
- ✅ Understand the rationale (why each change was made)
- ✅ Continue from any point (if stopped halfway)

### 5.2 What Destroys Handoff-Readiness?
- ❌ Assumed knowledge ("run the usual command")
- ❌ Missing context ("this is already set up")
- ❌ Implicit dependencies ("as we did before")
- ❌ Undocumented deviations ("I changed the plan a bit")

---

## Technology-Specific Guidance

### For Code Tasks (features, bug fixes, refactoring)
1. **Write tests first** (if the codebase has tests)
2. **Match existing style** exactly
3. **Minimal changes** — only touch what the task requires
4. **Verify edge cases** — null, empty, error paths

### For Infrastructure Tasks (deployment, configuration, provisioning)
1. **Validate prerequisites** before touching anything
2. **Use declarative configuration** — commit all config files
3. **Make scripts idempotent** — safe to run multiple times
4. **Add health checks** — verify deployment succeeded
5. **Document rollback** — how to undo
6. **Record access info** — URLs, IPs, credentials location

### For Documentation Tasks
1. **Read existing docs** first
2. **Match existing style** and formatting
3. **Update related docs** — don't leave stale references
4. **Verify accuracy** — test any commands you document

---

## Security Rules

1. **NEVER expose secrets** — passwords, tokens, keys
2. **NEVER commit secrets** — use env vars, secret managers, or gitignore
3. **Check credential storage** — where do secrets live? Are they secure?
4. **Minimize permissions** — don't use root/admin unless required
5. **Clean up credentials** — remove temp access after use

---

## Example: Minimal Plan for a Simple Task

Even simple tasks need a plan:

```
## Objective
Fix null pointer in user authentication

## Context Snapshot
- Language: Python 3.11
- Framework: FastAPI
- Tests: pytest in tests/
- Test command: pytest tests/

## Files to Read
- src/auth.py (main auth logic)
- src/auth_test.py (existing tests)
- src/models.py (User model)

## Implementation Steps
1. File: src/auth.py
   Change: Add null check before accessing user.email
   Pattern: Existing null checks in src/utils.py
   Rationale: Prevents 500 error when user is None

## Test Plan
- Update: src/auth_test.py
- Add test: test_auth_with_null_user
- Assert: returns 401, not 500

## Verification
- Run: pytest tests/test_auth.py
- Expected: all tests pass
- Manual: POST /auth with missing user header
```

---

## Final Checklist

Before calling a plan complete, verify:

- [ ] Context Snapshot is filled (not empty)
- [ ] All files have explicit paths
- [ ] All commands are exact (not vague)
- [ ] Test plan names specific test files
- [ ] E2E verification has expected outputs
- [ ] Risks are documented with mitigations
- [ ] Rollback procedure exists
- [ ] Execution Log section is ready
- [ ] A fresh agent could execute this without asking questions

---

**If your plan passes this checklist, it's ready.**
