---
description: "Create a feature specification through the multi-agent SDD pipeline: builds a codebase knowledge base, a feature-scoped architecture analysis, a risk discovery, and a brainstorm, then writes the authoritative spec.md enriched by all four artifacts."
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

The text the user typed after `/speckit.sdd-orchestrator.specify` **is** the
feature description. Assume you always have it available in this conversation
even if `$ARGUMENTS` appears literally below. You **MUST** use it throughout this
entire workflow. Do not ask the user to repeat it unless they provided an empty
command.

---

## Your Job

You are the entry point for feature work in this project. When invoked, you run
the **entire pipeline yourself, inline, in this conversation** — you do NOT
delegate to a CLI, you do NOT spawn external subagents, and you do NOT stop early.
Execute every phase in order and produce every artifact before writing the spec.

```
Phase -1  Knowledge Base       → .codebase/graph.json + .codebase/knowledge-base.md
Phase  0  Architecture         → .codebase/architecture-analysis.md
Phase  1  Discovery            → <feature_dir>/discovery.md
Phase  1.5 Brainstorm          → <feature_dir>/brainstorm.md
Phase  2  Specification        → <feature_dir>/spec.md   ← AUTHORITATIVE
```

**RULE-016**: No phase may be skipped. **RULE-002/003/015**: Architecture before
Discovery; Discovery before Brainstorm; both before Specification.

If at any point you cannot complete a phase, STOP and report which phase failed
and why — do **not** fall back to editing code directly. This command produces a
specification; it never implements the feature.

---

## Pre-Execution: before_specify hooks

Check if `.specify/extensions.yml` exists. If it does, read it and look for
entries under `hooks.before_specify`. Filter out hooks with `enabled: false`.
For each executable mandatory hook (`optional: false`), emit:

```
EXECUTE_COMMAND: {command}
```

and wait for its result before continuing (this is typically the git extension
creating the feature branch). Announce optional hooks and let the user decide.
When emitting `EXECUTE_COMMAND: speckit.git.feature`, append the inferred
scope and a short name: `EXECUTE_COMMAND: speckit.git.feature --scope {FEATURE_SCOPE} {feature-short-name}`
(e.g., `EXECUTE_COMMAND: speckit.git.feature --scope front add-login-form`).
If the file is missing or unparseable, skip silently.

---

## Phase -1 — Repository Knowledge Base

Ensure a fresh, token-efficient knowledge graph exists so later phases don't
re-scan the whole repo.

1. If `.codebase/graph.json` exists and its `generated_at` is < 24h old AND no
   sentinel files changed (`**/package.json`, `**/*.entity.ts`, `**/*.module.ts`,
   `**/*.controller.ts`, migrations, `**/schema.prisma`, `.github/agents/**`),
   the graph is **fresh** — skip scanning and reuse it.
2. Otherwise scan the repository (workspace packages, modules/bounded contexts,
   entities & tables, API surface, messaging/events, shared abstractions,
   conventions, infrastructure) and write:
   - `.codebase/graph.json` — structured graph (packages, modules, entities,
     api_surface, messaging, conventions, infrastructure)
   - `.codebase/knowledge-base.md` — human-readable narrative summary

Report: `Phase -1 ✓ knowledge base [fresh | rebuilt]`.

---

## Phase 0 — Codebase Architecture Analysis

Using the knowledge base as the source of truth (not a fresh scan), analyze the
feature from `$ARGUMENTS` and write `.codebase/architecture-analysis.md` with:
Existing Architecture Overview, Related Modules, Existing Patterns, Existing
Abstractions, Potential Conflicts, **Reuse Opportunities**, **Integration
Points**, **Architectural Constraints**, Architectural Gaps, and a Verdict.

Cite specific module names, file paths, and table names. Report:
`Phase 0 ✓ .codebase/architecture-analysis.md`.

### Scope Inference

After writing `architecture-analysis.md`, determine which workspace packages
(`backoffice`, `front`, `mobile`) will be touched by this feature. Apply this
mapping to set `FEATURE_SCOPE`:

| Packages affected | FEATURE_SCOPE |
|---|---|
| backoffice + front + mobile (all three) | `monorepo` |
| backoffice + front | `backoffice-front` |
| backoffice + mobile | `backoffice-mobile` |
| front + mobile | `front-mobile` |
| backoffice only | `backoffice` |
| front only | `front` |
| mobile only | `mobile` |

Log the result:
```
[sdd-orchestrator] Inferred scope: {FEATURE_SCOPE} (packages: {list})
```

Carry `FEATURE_SCOPE` forward — it is used in the before_specify hook below.

---

## Phase 1 — SDD Discovery

Act as a relentless challenger — break the feature before it is built. Using the
architecture analysis and knowledge base, work through: Assumptions, Missing
Requirements, Edge Cases, Failure Scenarios, Security Concerns (OWASP lens),
Scalability Concerns, Operational Concerns, Architectural Conflicts, Open
Questions, and Recommendations. Tag each finding with severity
(`critical|high|medium|low`) and type.

Write to `<feature_dir>/discovery.md` if the feature directory already exists,
otherwise to `.codebase/discovery-draft.md` (it will be moved into the feature
directory in Phase 2).

If discovery surfaces **critical** or **high** open questions, present them to
the user now:

```
⚠ Discovery surfaced <N> open question(s) to resolve before specification:

<list the critical/high open questions>

  A) Answer now (recommended for critical/high items)
  B) Proceed — unanswered questions become documented assumptions in spec.md
```

Incorporate any answers the user gives into the context for the next phases.
Report: `Phase 1 ✓ discovery.md`.

---

## Phase 1.5 — Brainstorm (Superpowers)

Run the `superpowers:brainstorming` skill to interactively refine intent,
requirements, and design **before** writing the spec. Use the architecture
analysis and discovery as input — focus the conversation on the open questions
and risks they surfaced.

- Read and follow the `superpowers:brainstorming` skill fully.
- Ask questions one at a time; explore the codebase when a question can be
  answered from it; resolve fuzzy or overloaded terminology.
- Continue until a shared, precise understanding is reached.

Capture the outcome — resolved decisions, chosen approach, rejected alternatives
and why, and agreed terminology — in `<feature_dir>/brainstorm.md` (or
`.codebase/brainstorm-draft.md` if the feature directory does not exist yet, to
be moved in Phase 2). Report: `Phase 1.5 ✓ brainstorm.md`.

> `discovery.md` (automated risk analysis) and `brainstorm.md` (interactive
> refinement) are complementary — both are produced and both feed the spec.

---

## Phase 2 — Specification

Now write the authoritative `spec.md`, enriched by all four artifacts. Advisory
artifacts inform the spec but never replace it — the spec you write is the single
source of truth (RULE-001, RULE-010, RULE-011).

1. **Generate a concise short name** (2–4 words, action-noun, preserve
   acronyms): e.g. `add-user-auth`, `fix-payment-timeout`.

2. **Create the feature directory:**

   ```bash
   bash .specify/scripts/bash/create-new-feature.sh "<short-name>" --json
   ```

   Parse `FEATURE_DIR` from the JSON output. Use it for all paths below. (If a
   `before_specify` hook already created the branch, reuse the values it emitted.)

3. **Move drafts into the feature directory** (if they exist):
   - `.codebase/discovery-draft.md` → `<FEATURE_DIR>/discovery.md`
   - `.codebase/brainstorm-draft.md` → `<FEATURE_DIR>/brainstorm.md`

4. **Write `<FEATURE_DIR>/spec.md`** from `.specify/templates/spec-template.md`,
   injecting:
   - The feature description from `$ARGUMENTS`
   - **`brainstorm.md`** — resolved decisions, chosen approach, terminology
     (primary source for scope and intent)
   - **`architecture-analysis.md`** — Reuse Opportunities, Integration Points,
     Architectural Constraints → spec Constraints & Dependencies
   - **`discovery.md`** — Missing Requirements, Recommendations, high/critical
     risks → spec Acceptance Criteria, Business Rules, Known Risks

   The spec must include: Functional Requirements, Non-Functional Requirements,
   Acceptance Criteria, Business Rules, Constraints (cite architecture analysis),
   Dependencies (modules/services/entities from the knowledge base), and Known
   Risks (high/critical from discovery).

5. **Persist the resolved path** to `.specify/feature.json`:

   ```json
   { "feature_directory": "<resolved FEATURE_DIR>" }
   ```

Report: `Phase 2 ✓ spec.md`.

---

## Post-Execution: after_specify hooks

After `spec.md` is written, check `.specify/extensions.yml` for
`hooks.after_specify`. Filter out `enabled: false`. For each mandatory hook
(`optional: false`), emit:

```
EXECUTE_COMMAND: {command}
```

and wait for the result (this is what runs `speckit.sdd-orchestrator.generate`).
Announce optional hooks for confirmation. Skip silently if none.

---

## Completion

Output the pipeline summary:

```
✅ SDD Specification Pipeline complete

Phase -1 (Knowledge Base):  ✓ [fresh | rebuilt]
Phase  0 (Architecture):    ✓ .codebase/architecture-analysis.md
Phase  1 (Discovery):       ✓ <FEATURE_DIR>/discovery.md
Phase  1.5 (Brainstorm):    ✓ <FEATURE_DIR>/brainstorm.md
Phase  2 (Specification):   ✓ <FEATURE_DIR>/spec.md  ← single source of truth

Advisory artifacts: architecture-analysis.md, discovery.md, brainstorm.md

Next: /speckit.plan — generate the implementation plan
```
