<!-- SPECKIT-ORCHESTRATOR START -->

# SDD Orchestrator — Project Instructions

This project uses the **Multi-Agent Spec-Driven Development (SDD) Orchestrator** workflow.
All feature work follows the pipeline defined in `Multi-Agent SDD Orchestrator.md`.

---

## RULE-016: No agent may bypass any workflow phase.

The mandatory execution order is:

```
Phase -1  codebase.index       → .codebase/graph.json + knowledge-base.md
Phase  0  codebase.architect   → .codebase/architecture-analysis.md
Phase  1  sdd.discovery        → <feature_dir>/discovery.md
Phase  2  speckit.specify      → <feature_dir>/spec.md          ← AUTHORITATIVE
Phase  3  speckit.plan         → <feature_dir>/plan.md          ← AUTHORITATIVE
Phase  4  speckit.tasks        → <feature_dir>/tasks.md         ← AUTHORITATIVE
Phase  5  sdd.route            → tasks.md annotated with →AgentName
Phase  6  sdd.implement        → parallel execution by phase
```

---

## Override: /speckit.specify → sdd.specify

**IMPORTANT:** `/speckit.specify` is overridden in this project.

When the user runs `/speckit.specify` or the `speckit.specify` agent is invoked:

1. **Do NOT run the stock speckit.specify logic directly.**
2. Instead, invoke the `sdd.specify` agent, passing the full feature description.
3. `sdd.specify` will orchestrate Phases -1, 0, 1, and then delegate back to Spec-Kit for Phase 2.

This override applies whenever the user says:

- "speckit specify", "/speckit.specify", "create a spec", "specify this feature"
- or the `speckit.specify` agent is spawned

---

## Override: /speckit.implement → sdd.implement

**IMPORTANT:** `/speckit.implement` is overridden in this project.

When the user runs `/speckit.implement` or the `speckit.implement` agent is invoked:

1. **Do NOT execute tasks sequentially.**
2. Instead, invoke the `sdd.implement` agent.
3. `sdd.implement` will verify routing, then fan out to specialist agents in parallel per phase.

This override applies whenever the user says:

- "speckit implement", "implement the tasks", "implement the speckit tasks"
- or the `speckit.implement` agent is spawned

---

## Single Source of Truth

Authoritative files (RULE-001):

- `spec.md` — requirements
- `plan.md` — design
- `tasks.md` — work items

Advisory files (inform but do NOT replace authoritative files):

- `.codebase/architecture-analysis.md`
- `discovery.md`
- `.codebase/knowledge-base.md`

Execution agents must NEVER make implementation decisions based solely on advisory artifacts.

---

## Hook Execution — Mandatory Protocol

After **every** speckit command completes, run ALL hooks for the corresponding event.

```bash
bash .specify/scripts/bash/list-hooks.sh <event>
```

Event mapping:

| After completing...  | Event name           |
| -------------------- | -------------------- |
| speckit.specify      | `after_specify`      |
| speckit.clarify      | `after_clarify`      |
| speckit.plan         | `after_plan`         |
| speckit.tasks        | `after_tasks`        |
| speckit.implement    | `after_implement`    |
| speckit.checklist    | `after_checklist`    |
| speckit.analyze      | `after_analyze`      |
| speckit.constitution | `after_constitution` |

Process every output line:

- `OPTIONAL=false` → execute immediately
- `OPTIONAL=true` → announce to user and ask for confirmation

---

## Execution Agents (Phase 6)

| Agent                | Domain                                |
| -------------------- | ------------------------------------- |
| `speckit.sdd-orchestrator.backend`  | NestJS services, controllers, modules |
| `speckit.sdd-orchestrator.database` | Entities, migrations, repositories    |
| `speckit.sdd-orchestrator.security` | Auth guards, validation, OWASP        |
| `speckit.sdd-orchestrator.qa`       | Tests, factories, coverage            |
| `speckit.sdd-orchestrator.infra`    | Docker, CI/CD, env config             |
| `speckit.sdd-orchestrator.reviewer` | Code review, acceptance sign-off      |

---

## Mandatory Behaviors for All Execution Agents

**Test Driven Development (RULE-012):**

1. Write tests first
2. Run → confirm RED
3. Implement
4. Run → confirm GREEN
5. Refactor
6. Run → confirm still GREEN

Implementation without tests is **forbidden**.

**Subagent Driven Development (RULE-013):**
Large tasks and cross-domain work MUST be delegated to the appropriate specialist agent.

---

## Extension Integration: sdd-orchestrator

This repository uses the `sdd-orchestrator` Spec Kit extension to connect Spec Kit with Squad and Superpowers.

- After `/speckit.tasks`, the configured `after_tasks` hook runs `sdd.route`.
- `sdd.route` annotates `tasks.md` with `→AgentName` assignments for the specialist agents defined in `.github/agents`.
- The extension enforces this project’s custom SDD workflow by integrating `sdd.specify`, `sdd.implement`, and `sdd.discovery` orchestration.
- Keep the `.github/agents` files in sync with the extension whenever task routing or specialist behavior changes.

<!-- SPECKIT-ORCHESTRATOR END -->

<!-- SPECKIT HOOKS -->

## Hook Execution — Mandatory Protocol

After **every** speckit command completes, you MUST run ALL hooks for the corresponding event.

**Never skip a hook because you already processed the first one.**

### How to do it

1. Run the hook list script to get every hook for the event:

   ```
   bash .specify/scripts/bash/list-hooks.sh <event>
   ```

   Replace `<event>` with the event name (e.g., `after_tasks`, `after_specify`).

2. The script outputs one line per enabled hook:

   ```
   COMMAND=sdd.route OPTIONAL=false PROMPT=Routing tasks to Squad agents...
   ```

3. Process **every line**:
   - `OPTIONAL=false` → execute immediately with `runSubagent("<COMMAND>")`
   - `OPTIONAL=true` → announce to the user and ask for confirmation before executing

### Event ↔ Command mapping

| After completing...  | Event name           |
| -------------------- | -------------------- |
| speckit.specify      | `after_specify`      |
| speckit.plan         | `after_plan`         |
| speckit.tasks        | `after_tasks`        |
| speckit.implement    | `after_implement`    |
| speckit.constitution | `after_constitution` |

Same pattern applies to `before_*` hooks (run the script with the before event name before invoking the command).

<!-- END SPECKIT HOOKS -->
