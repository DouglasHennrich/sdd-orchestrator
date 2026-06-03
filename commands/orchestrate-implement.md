---
description: "Orchestrated implement — verifies task routing then fans out to specialist agents per phase (Phase 6)."
---

## User Input

```text
$ARGUMENTS
```

---

## SDD Execution Orchestrator

This is the orchestrated entry point for implementation. When invoked, you execute
everything **inline in this conversation** — Phase 5 (Task Routing) → Phase 6 (Execution).

**RULE-007**: Routing must always execute before Implementation.
**RULE-012**: All implementation must follow Test Driven Development.
**RULE-013**: All execution agents must support Subagent Driven Development.
**RULE-014**: No implementation may begin before routing is completed.

---

## Pre-Execution Checks

### 1 — Extension Hooks (before_implement)

Check `.specify/extensions.yml` for `hooks.before_implement`. Filter out hooks
with `enabled: false`. For each mandatory hook (`optional: false`), emit
`EXECUTE_COMMAND: {command}` and wait for the result. Announce optional hooks.
Skip silently if none.

### 2 — Prerequisites

Run:

```bash
bash .specify/scripts/bash/check-prerequisites.sh --json --require-tasks --include-tasks
```

Parse `FEATURE_DIR` and `AVAILABLE_DOCS`. All paths must be absolute.

### 3 — Required Artifacts

Verify these files exist in `FEATURE_DIR`. Stop if any is missing:

| File | Required | Purpose |
|---|---|---|
| `spec.md` | ✅ | Authoritative requirements |
| `plan.md` | ✅ | Technical design |
| `tasks.md` | ✅ | Implementation tasks |

Advisory artifacts (load if present, do not block if missing):

| File | Purpose |
|---|---|
| `.codebase/architecture-analysis.md` | Architectural constraints |
| `discovery.md` | Risk context |

### 4 — Routing Check

Scan `tasks.md` for unchecked tasks (`- [ ]`). Every unchecked task MUST have
a `→AgentName` annotation. If any unchecked task lacks one, stop and report:

> "Tasks are not routed. Run `/speckit.sdd-orchestrator.route` before implementing."

---

## Phase 5 — Task Routing (if not yet done)

If routing annotations are present, skip this section.

If routing has NOT been performed yet, run it now by emitting:

```
EXECUTE_COMMAND: speckit.sdd-orchestrator.route
```

Wait for routing to complete (tasks.md annotated with `→AgentName`) before
proceeding to execution.

---

## Phase 6 — Parallel Execution by Phase

### Step 1 — Parse Tasks

Read all unchecked tasks (`- [ ]`) from `tasks.md`.
Group by:

1. **Phase** — tasks.md is organized in phases; Phase N must complete before Phase N+1
2. **Agent** — the `→AgentName` annotation

### Step 2 — Execution Rules

**RULE-008**: Squad routes tasks but does NOT modify them.
**RULE-009**: Execution agents implement tasks but do NOT redefine requirements.

Each execution agent receives:

- Its assigned task list (with full task text and acceptance criteria)
- The full `spec.md` (read-only — authoritative)
- The full `plan.md` (read-only — authoritative)
- Path to `architecture-analysis.md` (advisory — for architectural context)
- Mandatory behavior: **Test Driven Development** (RULE-012)
- Mandatory behavior: **Subagent Driven Development** when specialization needed (RULE-013)

### Step 3 — TDD Enforcement

Every implementation agent MUST follow this sequence per task:

```
1. Write tests first
2. Run tests → confirm RED (failure)
3. Implement the minimum solution
4. Run tests → confirm GREEN (pass)
5. Refactor
6. Run tests → confirm still GREEN
```

Implementation without tests is **forbidden** (RULE-012).

### Step 4 — Phase-by-Phase Parallel Dispatch

```
For each PHASE in tasks.md (in order):
  1. Group unchecked tasks in this phase by →AgentName
  2. Spawn ALL agents for this phase IN PARALLEL
  3. Wait for ALL agents in this phase to complete
  4. Mark all completed tasks in tasks.md as checked [x]
  5. Proceed to next phase
```

Supported execution agents:

| Agent | Domain |
|---|---|
| `speckit.sdd-orchestrator.backend` | NestJS services, controllers, modules, DTOs |
| `speckit.sdd-orchestrator.database` | Entities, migrations, repositories, queries |
| `speckit.sdd-orchestrator.infra` | Docker, CI/CD, environment config |
| `speckit.sdd-orchestrator.security` | Auth guards, validation, OWASP review |
| `speckit.sdd-orchestrator.qa` | Tests, test factories, E2E specs |
| `speckit.sdd-orchestrator.reviewer` | Code review, acceptance criteria verification |

### Step 5 — Subagent Delegation Examples

Agents MUST delegate specialized work:

```
speckit.sdd-orchestrator.backend  → speckit.sdd-orchestrator.database   (when entity/migration work is needed)
speckit.sdd-orchestrator.backend  → speckit.sdd-orchestrator.security   (when auth/validation is involved)
speckit.sdd-orchestrator.backend  → speckit.sdd-orchestrator.qa         (when test factories are needed)
speckit.sdd-orchestrator.infra    → speckit.sdd-orchestrator.security   (when secrets/env config is involved)
speckit.sdd-orchestrator.reviewer → speckit.sdd-orchestrator.qa         (when test coverage needs verification)
```

---

## Completion

After all phases complete:

1. Run `after_implement` hooks: check `.specify/extensions.yml` for
   `hooks.after_implement`, and for each mandatory hook emit
   `EXECUTE_COMMAND: {command}`. Announce optional hooks. Skip silently if none.

2. Output final summary:

```
✅ SDD Execution complete

Phases executed: <N>
Tasks completed: <N>/<total>

Artifacts verified:
  spec.md    ← requirements honored
  plan.md    ← design followed
  tasks.md   ← all tasks checked

TDD: all implementations include passing tests
SDD: specialist delegation applied where needed

Next: /speckit.analyze to verify cross-artifact consistency
```
