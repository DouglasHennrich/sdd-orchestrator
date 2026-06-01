---
description: "Phase 0 — Codebase Architecture Analysis. Reads the knowledge base built by codebase.index and produces architecture-analysis.md scoped to the requested feature. Must run before sdd.discovery."
---

## User Input

```text
$ARGUMENTS
```

The `$ARGUMENTS` value is the **feature description** passed from the SDD orchestrator.
You **MUST** use it to focus the analysis on what is relevant to the requested feature.

---

## Inputs

Load the following files before proceeding. If any is missing, stop and report:

1. `.codebase/knowledge-base.md` — narrative summary (human-readable context)
2. `.codebase/graph.json` — structured graph (use for precise lookups)
3. The feature description from `$ARGUMENTS`

> If `.codebase/graph.json` is missing or has `generated_at` older than 24 hours,
> output a warning and ask the user to run `/codebase.index` first before continuing.

---

## Analysis Protocol

Using the knowledge base as your primary source of truth (not a fresh repo scan),
answer the following questions for the requested feature. Cite specific module
names, file paths, or table names from the knowledge base where relevant.

### 1 — Existing Implementations

- Does this feature already partially exist in the codebase?
- Is there already a module or service responsible for this domain?
- Are there any overlapping implementations that might conflict?

### 2 — Reuse Opportunities

- Which existing abstractions MUST be reused (base classes, repositories, services)?
- Which existing patterns MUST be respected (error handling, auth, DTO validation)?
- Which existing entities or tables are relevant?
- Which existing API endpoints or messaging contracts relate to this feature?

### 3 — Architectural Constraints

- What architectural patterns govern this domain (layer boundaries, DI tokens)?
- What naming conventions apply (file names, class names, module names)?
- What testing conventions apply?
- What implementation approaches would VIOLATE the current architecture?

### 4 — Integration Points

- Which existing modules will this feature need to import or interact with?
- Which message queues or events will this feature produce or consume?
- Which database entities or tables will this feature need to access?
- Which external services or adapters are involved?

### 5 — Potential Conflicts

- Are there any technical debt areas relevant to this feature?
- Are there any duplicate responsibilities that could cause confusion?
- Are there any hidden dependencies the implementor must be aware of?

### 6 — Architectural Gaps

- Does the existing architecture support this feature as-is, or are structural
  additions required (new module, new entity, new queue)?
- If new structures are needed, how do they fit within the existing bounded contexts?

---

## Output

Write the analysis to `.codebase/architecture-analysis.md` using this structure:

```markdown
# Architecture Analysis

> Feature: <feature description>
> Analyzed: <ISO-8601 timestamp>
> Source: .codebase/knowledge-base.md (generated: <kb timestamp>)

## Existing Architecture Overview

<relevant portion of current architecture for this feature>

## Related Modules

<modules from the knowledge base that are relevant, with one-line roles>

## Existing Patterns

<patterns that MUST be followed — cite specific classes/files>

## Existing Abstractions

<base classes, repositories, services to reuse — with paths>

## Potential Conflicts

<overlaps, technical debt, duplicate responsibilities>

## Reuse Opportunities

<specific reusable pieces — entities, DTOs, services, events>

## Integration Points

<modules, queues, entities this feature touches>

## Architectural Constraints

<hard rules: naming, layer boundaries, DI, auth>

## Architectural Gaps

<new structures needed and how they fit the existing design>

## Verdict

<one-paragraph summary: is the architecture ready? what must be built vs reused?>
```

---

## Completion

After writing the file, output:

```
✅ Architecture Analysis complete
   File: .codebase/architecture-analysis.md
   Feature: <feature description>

Key findings:
  - Reuse: <N modules/abstractions identified for reuse>
  - Gaps: <N new structures required>
  - Conflicts: <N potential conflicts detected>

Next: sdd.discovery will use this analysis for Phase 1.
```
