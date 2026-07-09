---
name: coding-principles
description: Review code through KISS, DRY, SOLID, and YAGNI lenses. Produces a ranked list of up to 3 high-impact changes, each tagged with the principle(s) and named conflict-resolution rule that drove it. Use when user says "review with coding principles", "KISS this", "DRY this up", "refactor with principles", or names a single principle.
---

<what-to-do>

Review the code the user is pointing at (a file, function, or diff). Walk it through the four lenses below, apply the conflict-resolution rules when lenses disagree, and output **at most 3 ranked changes**. Stop after 3 — the user can re-run for more.

For each change, output in this exact shape:

```
N. <one-sentence change> (<principles>, <named rule if a conflict was resolved>)
   Impact: <low|medium|high>
   Why: <1–2 sentences naming the specific code and the specific principle>
```

Do not implement the changes. Do not write tests. Do not redesign. The skill's job is **judgement**, not editing.

</what-to-do>

<supporting-info>

## The four lenses

### KISS — count the abstraction layers
For each function, count the layers between the input and the side effect. Flag any layer that doesn't earn its keep (a wrapper that only renames, a config object that only forwards, a factory that returns a single concrete class). A function that does 3 things in 30 lines beats 3 functions of 10 lines each if the latter adds no testability or reuse.

### DRY — rule of three
Find identical or near-identical blocks. Extract only after the **third** occurrence. Two copies is a coincidence, not a pattern. Three is. (This is the named rule: **rule of three**.) Prefer duplication over a wrong abstraction.

### SOLID — single reason to change
Per function or class, name **one** reason it would need to change. If you can't, it has more than one responsibility — split. This is the SRP sub-check. (The other four SOLID letters are deferred unless the user names them; the user's "crown jewel" review is SRP-focused.)

### YAGNI — name the user need
For each piece of code, name the **concrete, current** user-facing need it serves. If you can't, flag it. If the justification is "we might need it for…", cut it. (This is the named rule: **real need test**.)

## Conflict resolution

When two lenses disagree on the same code, apply the named rule mechanically and reference it in the output:

| Conflict | Resolution | Named rule |
|---|---|---|
| DRY says "extract", KISS says "the abstraction is heavier than the duplication" | Extract only after 3 repetitions | **rule of three** |
| YAGNI says "cut it", good design says "the interface needs that parameter" | Keep only if a concrete current user need exists | **real need test** |
| DRY says "this config will be reused", YAGNI says "only one consumer" | Reuse must be proven by 3 consumers | **third-consumer test** |

Always cite the named rule in the output so the user can audit the decision. A finding tagged `(KISS, DRY → rule of three)` is auditable; a finding tagged `(KISS, DRY)` is just an opinion.

## Out of scope

- Designing new systems (use `grill-with-docs`).
- Writing tests (use `tdd`).
- Implementing the changes (the user reads the ranked list and acts).
- Performance profiling, security review, accessibility audit — different skills, different lenses.

</supporting-info>
