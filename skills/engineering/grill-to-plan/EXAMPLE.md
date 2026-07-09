# Example output of /grill-to-plan

This is what a synthesized plan looks like after grilling.

# AI Execution Plan — Example Task

## Context Snapshot

- **Repo:** example
- **Branch:** feature/example
- **Goal:** Add feature X.

## Files to Read / Modify

| File | Why |
|------|-----|
| `src/x.go` | Add feature X implementation. |
| `src/x_test.go` | Add tests. |

## Implementation Steps

1. Read `src/x.go`.
2. Add feature X.
3. Add tests.

## Test Plan

| Layer | Command | Expected |
|-------|---------|----------|
| Unit | `go test ./...` | pass |

## E2E Verification

Run feature X manually and confirm output.

## Risks and Mitigations

| Risk | Mitigation |
|------|-----------|
| Breaks existing tests | Run full suite. |

## Rollback Procedure

```bash
git checkout -- src/x.go src/x_test.go
```

## Execution Log

*(To be filled during implementation.)*
