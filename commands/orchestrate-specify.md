---
description: "Orchestrated specify — runs the full SDD pipeline (knowledge base, architecture, discovery, brainstorm) then writes the authoritative spec.md."
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

Run the `speckit.sdd-orchestrator.specify` agent with the full feature
description. The agent executes every phase **inline** in the conversation — it
does not spawn external subagents or require a CLI — and produces all artifacts
before writing the spec:

```
Phase -1   Knowledge Base   → .codebase/graph.json + knowledge-base.md
Phase  0   Architecture     → .codebase/architecture-analysis.md
Phase  1   Discovery        → <feature_dir>/discovery.md
Phase  1.5 Brainstorm       → <feature_dir>/brainstorm.md   (superpowers:brainstorming)
Phase  2   Specification    → <feature_dir>/spec.md   ← AUTHORITATIVE
```

The spec is enriched by `brainstorm.md` + `discovery.md` +
`architecture-analysis.md`. The agent processes `before_specify` /
`after_specify` hooks via `EXECUTE_COMMAND:` markers (the `after_specify` hook
runs `speckit.sdd-orchestrator.generate` to keep Squad agents aligned).

## Notes

- Advisory artifacts enrich the spec but never replace it. `spec.md` is the
  single source of truth (RULE-001).
- The agent must complete all phases; it never falls back to editing code
  directly. This command produces a specification only.
