---
description: "Phase 1 — discovery: surface risks, missing requirements, and open questions before the spec is written."
---

# SDD Orchestrator — Discovery (Phase 1)

## User Input

```text
$ARGUMENTS
```

Run the `speckit.sdd-orchestrator.discovery` agent, passing the feature
description from `$ARGUMENTS`. It challenges assumptions and surfaces risks,
writing either:

- `<feature_dir>/discovery.md` (if the feature directory already exists), or
- `.codebase/discovery-draft.md` (if specify has not yet created the feature
  directory — this draft is moved into place during Phase 2).

If discovery surfaces **Critical** or **High** severity open questions, present
them to the user before specification proceeds. This command is normally invoked
automatically by `speckit.sdd-orchestrator.specify` (Phase 1).
