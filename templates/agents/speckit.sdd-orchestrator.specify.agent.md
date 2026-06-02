---
description: "SDD Orchestrator entry point. Intercepts /speckit.specify and runs the full SDD pre-specification pipeline (Phase -1 → 0 → 1) before delegating to Spec-Kit. REPLACES the stock speckit.specify agent for this project."
handoffs:
  - label: Build Technical Plan
    agent: speckit.plan
    prompt: Create a plan for the spec. I am building with...
  - label: Clarify Spec Requirements
    agent: speckit.clarify
    prompt: Clarify specification requirements
    send: true
---

## User Input

```text
$ARGUMENTS
```

You **MUST** use the feature description from `$ARGUMENTS` throughout this entire workflow.

---

## SDD Orchestrator — Pre-Specification Pipeline

This agent is the **entry point** for all feature work in this project.

Before any specification is written, it enforces the full SDD pipeline defined in
`Multi-Agent SDD Orchestrator.md`:

```
Phase -1 → Phase 0 → Phase 1 → Phase 2 (Spec-Kit Specify)
```

**RULE-002**: Architecture Analysis must always execute before Discovery.
**RULE-003**: Discovery must always execute before Specification.
**RULE-015**: Codebase Architect findings must be considered before any specification.
**RULE-016**: No agent may bypass any workflow phase.

---

## Pre-Execution: Git Branch Hook

Before running any phase, process extension hooks:

Check `.specify/extensions.yml` for `hooks.before_specify` entries and execute
them per the standard Spec-Kit hook protocol (mandatory hooks run immediately,
optional hooks are announced to the user).

**IMPORTANT:** This orchestrator must be invoked through the global `specify`
CLI so that hook execution and extension commands are resolved properly. Do not
invoke a local `speckit` binary directly for this flow.

---

## Phase -1 — Repository Knowledge Base

**Purpose:** Ensure a fresh, token-efficient knowledge graph exists so subsequent
phases do not re-scan the entire monorepo.

Run as a subagent:

```
Spawn: speckit.sdd-orchestrator.codebase-index
Arguments: (none — codebase-index performs its own staleness check)
```

Wait for completion. If `speckit.sdd-orchestrator.codebase-index` reports the graph is already fresh
(staleness check passed), proceed immediately to Phase 0.

If `speckit.sdd-orchestrator.codebase-index` fails or reports errors, stop the pipeline and report:

> "Phase -1 failed. Knowledge base could not be built. Resolve the issue and retry."

---

## Phase 0 — Codebase Architecture Analysis

**Purpose:** Produce a feature-scoped architecture analysis using the knowledge base.

Run as a subagent:

```
Spawn: speckit.sdd-orchestrator.codebase-architect
Arguments: <exact feature description from $ARGUMENTS>
```

Wait for completion. Verify `.codebase/architecture-analysis.md` was written.

If the file is missing after the subagent completes, stop and report:

> "Phase 0 failed. architecture-analysis.md was not produced. Cannot proceed."

---

## Phase 1 — SDD Discovery

**Purpose:** Challenge assumptions, surface risks, and generate open questions
before the spec is written.

Run as a subagent:

```
Spawn: speckit.sdd-orchestrator.discovery
Arguments: <exact feature description from $ARGUMENTS>
```

Wait for completion. Check for:

- `discovery.md` in the feature directory (if `.specify/feature.json` exists), OR
- `.codebase/discovery-draft.md` (if specify hasn't run yet — this is expected)

If neither file exists after the subagent completes, stop and report:

> "Phase 1 failed. discovery.md was not produced. Cannot proceed."

**Important:** `speckit.sdd-orchestrator.discovery` may surface **Critical** or **High** severity open
questions. Present these to the user before proceeding:

```
⚠ Discovery surfaced <N> open question(s) that should be resolved before specification:

<list open questions from discovery output>

You may:
  A) Answer these questions now (recommended for critical/high items)
  B) Proceed anyway — unanswered questions will be noted as assumptions in spec.md
```

If the user chooses to answer questions, incorporate their answers into the
`$ARGUMENTS` context before proceeding to Phase 2.

---

## Phase 2 — Specification (Spec-Kit)

**Purpose:** Generate the authoritative `spec.md` using Spec-Kit, enriched by
the advisory artifacts from Phases 0 and 1.

Now execute the **stock Spec-Kit specify logic** below, with these additions:

**Additional context to inject into the specification:**

- Read `.codebase/architecture-analysis.md` — use its "Reuse Opportunities",
  "Integration Points", and "Architectural Constraints" sections to inform
  the spec's constraints and dependencies sections.
- Read the discovery file — use its "Missing Requirements" and
  "Recommendations" sections to inform acceptance criteria and business rules.
- Advisory artifacts enrich the spec but do NOT replace it (RULE-010, RULE-011).
  The spec you write is the authoritative source.

---

## Spec-Kit Specify — Standard Outline

From this point forward, follow the standard Spec-Kit specify protocol:

1. **Generate a concise short name** (2–4 words) for the feature using the
   feature description. Use action-noun format (e.g., "add-user-auth",
   "fix-payment-timeout"). Preserve technical terms and acronyms.

2. **Run the feature creation script:**

   ```bash
   bash .specify/scripts/bash/create-new-feature.sh "<short-name>" --json
   ```

   Parse `FEATURE_DIR` from the output. All subsequent file paths use this dir.

3. **Move discovery draft** (if it exists):
   If `.codebase/discovery-draft.md` exists, move it to `<FEATURE_DIR>/discovery.md`.

4. **Write `<FEATURE_DIR>/spec.md`** using the spec template
   (`.specify/templates/spec-template.md`), incorporating:
   - The feature description from `$ARGUMENTS`
   - User answers to open questions (if any were provided)
   - Constraints and dependencies from `architecture-analysis.md`
   - Recommendations from `discovery.md`

   The spec must include:
   - Functional Requirements
   - Non-Functional Requirements
   - Acceptance Criteria
   - Business Rules
   - Constraints (referencing architecture analysis)
   - Dependencies (modules, services, entities from knowledge base)
   - Known Risks (from discovery — high/critical items)

5. **Update `.specify/feature.json`** with the new `feature_directory`.

6. **Run after_specify hooks:**
   ```bash
   bash .specify/scripts/bash/list-hooks.sh after_specify
   ```
   Execute all hooks per the standard hook protocol.

---

## Completion

After all phases complete, output a pipeline summary:

```
✅ SDD Pre-Specification Pipeline complete

Phase -1 (Knowledge Base): ✓ [fresh | rebuilt]
Phase  0 (Architecture):   ✓ .codebase/architecture-analysis.md
Phase  1 (Discovery):      ✓ <FEATURE_DIR>/discovery.md
Phase  2 (Specification):  ✓ <FEATURE_DIR>/spec.md

Advisory artifacts produced:
  - .codebase/architecture-analysis.md (project-level, reused across features)
  - <FEATURE_DIR>/discovery.md (feature-scoped, advisory only)

Authoritative artifact:
  - <FEATURE_DIR>/spec.md ← single source of truth

Next steps:
  /speckit.plan — generate the implementation plan
```
