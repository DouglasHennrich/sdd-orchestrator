<!-- SPECKIT-ORCHESTRATOR START -->

# SDD Orchestrator — Project Instructions

This project uses the **Multi-Agent Spec-Driven Development (SDD) Orchestrator** workflow.
All feature work follows the pipeline defined in `Multi-Agent SDD Orchestrator.md`.

---

## RULE-016: No agent may bypass any workflow phase.

The mandatory execution order is:

```
Phase -1   Knowledge Base   → .codebase/graph.json + knowledge-base.md
Phase  0   Architecture     → .codebase/architecture-analysis.md
Phase  1   Discovery        → <feature_dir>/discovery.md
Phase  1.5 Brainstorm       → <feature_dir>/brainstorm.md   (superpowers:brainstorming)
Phase  2   speckit.specify  → <feature_dir>/spec.md          ← AUTHORITATIVE
Phase  3   speckit.plan     → <feature_dir>/plan.md          ← AUTHORITATIVE
Phase  4   speckit.tasks    → <feature_dir>/tasks.md         ← AUTHORITATIVE
Phase  5   speckit.sdd-orchestrator.route       → tasks.md annotated with →AgentName
Phase  6   speckit.sdd-orchestrator.implement   → parallel execution by phase
```

Phases -1 through 2 run **inline** inside `speckit.sdd-orchestrator.specify`
when the user invokes `/speckit.sdd-orchestrator.specify`. The agent produces
all four pre-spec artifacts (knowledge base, architecture analysis, discovery,
brainstorm) and injects `brainstorm.md` + `discovery.md` +
`architecture-analysis.md` into the authoritative `spec.md`.

---

## Entry point: use the orchestrated commands, not the stock ones

**IMPORTANT:** Spec-Kit cannot literally rewrite what `/speckit.specify` does — a
slash command always runs its own registered template. To get the SDD pipeline
you must run the **orchestrated** commands this extension registers:

| Instead of running… | Run the orchestrated command… |
| ------------------- | ----------------------------- |
| `/speckit.specify`  | `/speckit.sdd-orchestrator.specify`  |
| `/speckit.implement`| `/speckit.sdd-orchestrator.implement`|

When the user asks to "specify a feature", "create a spec", or types
`/speckit.sdd-orchestrator.specify`:

1. **Do NOT run the stock `speckit.specify` logic directly.**
2. Run the `speckit.sdd-orchestrator.specify` agent with the full feature
   description. It executes Phases -1 → 0 → 1 → 1.5 → 2 **inline** in the
   conversation, producing all four artifacts and writing `spec.md`.
3. **Do NOT start editing code.** This command produces a *specification*, never
   an implementation. If a phase cannot complete, STOP and report which phase
   failed — never silently fall back to editing files.

When the user asks to "implement the tasks" or types
`/speckit.sdd-orchestrator.implement`:

1. **Do NOT execute tasks sequentially.**
2. Run the `speckit.sdd-orchestrator.implement` agent. It verifies `→AgentName`
   routing (running `speckit.sdd-orchestrator.route` first if needed via
   `EXECUTE_COMMAND:`), then fans out to specialist agents in parallel per phase.

**Mechanism note (VS Code Copilot Chat):** the orchestrator agents run every
phase inline. To chain a registered command (a hook or `route`), they emit an
`EXECUTE_COMMAND: {command}` marker — they never "spawn" external subagents and
never require a CLI binary. Requires Spec-Kit `>=0.8.18` (earlier versions do not
wire `before_specify`/`after_specify` into the specify command template).

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

After `speckit.sdd-orchestrator.specify` completes, the orchestrator should display a phase summary with check markers for each step, for example:

```
Phase -1  speckit.sdd-orchestrator.codebase-index       ✓ .codebase/graph.json + knowledge-base.md
Phase  0  speckit.sdd-orchestrator.codebase-architect   ✓ .codebase/architecture-analysis.md
Phase  1  speckit.sdd-orchestrator.discovery        ✓ <feature_dir>/discovery.md
Phase  2  speckit.specify      ✓ <feature_dir>/spec.md
Phase  3  speckit.plan         ✓ <feature_dir>/plan.md
Phase  4  speckit.tasks        ✓ <feature_dir>/tasks.md
Phase  5  speckit.sdd-orchestrator.route            ✓ tasks.md annotated with →AgentName
Phase  6  speckit.sdd-orchestrator.implement        ✓ parallel execution by phase
```

This makes the executed workflow visible and confirms that each SDD phase was completed.

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

| Agent                               | Domain                                |
| ----------------------------------- | ------------------------------------- |
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

- After `/speckit.tasks`, the configured `after_tasks` hook runs `speckit.sdd-orchestrator.route`.
- `speckit.sdd-orchestrator.route` annotates `tasks.md` with `→AgentName` assignments for the specialist agents defined in `.github/agents`.
- The extension enforces this project’s custom SDD workflow by integrating `speckit.sdd-orchestrator.specify`, `speckit.sdd-orchestrator.implement`, and `speckit.sdd-orchestrator.discovery` orchestration.
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
   COMMAND=speckit.sdd-orchestrator.route OPTIONAL=false PROMPT=Routing tasks to Squad agents...
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
