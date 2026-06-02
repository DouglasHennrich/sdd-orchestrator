---
description: "Orchestrated specify — runs the SDD pre-specification pipeline (Phase -1 → 0 → 1) then the stock speckit.specify (Phase 2)."
---

# SDD Orchestrator — Specify

This is the **entry point** for feature work in this project. Run it instead of
`/speckit.specify` to get the full multi-agent SDD pipeline.

## User Input

```text
$ARGUMENTS
```

You **MUST** use the feature description from `$ARGUMENTS` throughout this flow.

## What this command does

Delegate to the `speckit.sdd-orchestrator.specify` agent, passing the full
feature description. That agent enforces the mandatory phase order:

```
Phase -1  speckit.sdd-orchestrator.codebase-index      → .codebase/graph.json + knowledge-base.md
Phase  0  speckit.sdd-orchestrator.codebase-architect  → .codebase/architecture-analysis.md
Phase  1  speckit.sdd-orchestrator.discovery           → <feature_dir>/discovery.md
Phase  2  speckit.specify (stock)                      → <feature_dir>/spec.md   ← AUTHORITATIVE
```

## Steps

1. **Process `before_specify` hooks.** Run:

   ```bash
   bash .specify/scripts/bash/list-hooks.sh before_specify
   ```

   For each `OPTIONAL=false` line, execute the command immediately. For each
   `OPTIONAL=true` line, announce it and ask the user before executing.

2. **Run the orchestrator agent.** Invoke the `speckit.sdd-orchestrator.specify`
   agent with the exact feature description from `$ARGUMENTS`. The agent runs
   Phases -1, 0, 1 (each as its registered sub-command), surfaces any
   Critical/High discovery questions to the user, then executes the **stock
   speckit.specify logic** to produce the authoritative `spec.md`.

3. **Process `after_specify` hooks.** After `spec.md` is written, run:

   ```bash
   bash .specify/scripts/bash/list-hooks.sh after_specify
   ```

   Execute every returned hook per the same OPTIONAL protocol as step 1. This is
   what triggers `speckit.sdd-orchestrator.generate` to keep Squad agents aligned.

4. **Print the phase summary** with check marks for each completed phase.

## Notes

- Advisory artifacts (`architecture-analysis.md`, `discovery.md`,
  `knowledge-base.md`) enrich the spec but never replace it. `spec.md` is the
  single source of truth (RULE-001).
- This flow must be launched through the global `specify` CLI so that hooks and
  extension sub-commands resolve correctly.
