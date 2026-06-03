# Changelog

## [1.7.0] - 2026-06-03

### Added

- **Monorepo scope branch naming.** The `sdd-orchestrator.init` script now patches three
  project files to produce scope-aware branch names like `007-front-add-login` instead of
  `007-add-login`:
  - **`create-new-feature.sh`** gains a `--scope` flag. When provided, the scope value is
    prepended to the branch suffix: `NNN-{scope}-feature-name`. The flag is optional —
    omitting it preserves existing behavior.
  - **`speckit.git.feature.agent.md`** (project copy) is updated to forward `--scope <value>`
    to the bash script when it is present in `$ARGUMENTS`.
  - **`speckit.git.validate.agent.md`** (project copy) is updated to accept the new
    `NNN-(scope)-name` pattern alongside the legacy `NNN-name` pattern for backward
    compatibility. Valid scope values: `monorepo`, `backoffice`, `front`, `mobile`,
    `backoffice-front`, `backoffice-mobile`, `front-mobile`.
  - All three patches are **idempotent** — re-running `speckit.sdd-orchestrator.init` after
    they are already applied skips them with a `[sdd-orchestrator] ... skipping.` message.

- **Scope inference in the specify agent.** `speckit.sdd-orchestrator.specify` now performs
  a **Scope Inference** step at the end of Phase 0, after architecture analysis. It maps
  which workspace packages (`backoffice`, `front`, `mobile`) will be touched to a
  `FEATURE_SCOPE` value using the priority table above, logs the result, and carries the
  value forward into the `before_specify` hook so the git feature command is invoked as
  `EXECUTE_COMMAND: speckit.git.feature --scope {FEATURE_SCOPE} {feature-short-name}`.

## [1.6.0] - 2026-06-03

### Changed

- **Routing now uses exclusively real Squad agents — domain agent templates removed.**
  The `route` and `after-tasks` commands previously had a hardcoded fallback table mapping
  domain keywords to `speckit.sdd-orchestrator.backend`, `.database`, `.security`, `.qa`,
  `.infra`, and `.reviewer`. This caused tasks to be routed to sdd-orchestrator's internal
  agent names instead of the actual Squad agents defined in `.squad/agents/` (e.g. `Jorge`,
  `backend-engineer`). The fallback table has been removed entirely.

- **`route.md` and `after-tasks.md`**: routing now reads exclusively from `.squad/agents/`
  active agents and `.squad/routing.md`. If no Squad agent covers a task, the command flags
  it with `⚠️ no agent match` and instructs the user to run
  `/speckit.sdd-orchestrator.generate` so a new Squad agent is created before retrying.
  A new prerequisite check ensures at least one active Squad agent exists before routing
  begins.

- **`orchestrate-implement.md`**: removed reference to "specialist execution agents
  (backend, database, security, qa, infra, reviewer)" — execution is now dispatched to
  whatever Squad agents are annotated in `tasks.md`.

### Removed

- **6 domain-role agent templates** that modelled Squad roles inside the orchestrator:
  `speckit.sdd-orchestrator.backend.agent.md`, `.database.agent.md`, `.security.agent.md`,
  `.qa.agent.md`, `.infra.agent.md`, `.reviewer.agent.md`. These were incorrect — domain
  agents belong to the Squad team (generated per-project by `generate`), not to the
  orchestrator itself. The remaining orchestrator-owned agents (`route`, `specify`,
  `discovery`, `codebase-index`, `codebase-architect`, `implement`, `tasks-auditor`) are
  process agents and are unaffected.

## [1.5.1] - 2026-06-02

### Fixed

- **`tasks-audit` command now executes inline instead of delegating via `EXECUTE_COMMAND:`.**
  The previous implementation emitted `EXECUTE_COMMAND: speckit.sdd-orchestrator.tasks-auditor`
  to delegate audit logic to the Squad agent — but when the command is invoked directly by the
  user (not via a hook), there is no orchestrator listening to process that marker, so execution
  stopped after printing the `EXECUTE_COMMAND:` line. The full audit agenda (resolve FEATURE_DIR,
  load tasks.md, verify, classify, produce report, retry loop, escalation) is now embedded
  directly in `commands/tasks-audit.md`, matching the inline execution pattern used by
  `speckit.sdd-orchestrator.implement`.

## [1.5.0] - 2026-06-02

### Added

- **Phase 7 — Tasks Audit (post-implementation).** After every implementation batch, the `tasks-auditor` Squad agent automatically audits every task in `tasks.md`, classifying each as `✅ done`, `⚠️ partial`, `❌ missing`, or `🔴 broken`. Failing tasks are re-routed to their `→AgentName` agent automatically, up to 3 retry cycles. Only after 3 consecutive failed cycles does the auditor escalate to the user with a structured report.
- **`after_implement` hook** in `extension.yml` pointing to `speckit.sdd-orchestrator.tasks-audit`. Triggers automatically when `/speckit.sdd-orchestrator.implement` completes.
- **`speckit.sdd-orchestrator.tasks-audit` command** (`commands/tasks-audit.md`). Thin orchestrator: verifies the `tasks-auditor` Squad agent exists (triggering `generate` if absent), then delegates the full audit and retry loop to it.
- **`speckit.sdd-orchestrator.tasks-auditor` agent template** (`templates/agents/speckit.sdd-orchestrator.tasks-auditor.agent.md`). Implements the full audit agenda: resolve FEATURE_DIR, load `tasks.md`, verify each task (file existence, Result pattern, ZodValidationPipe, Presenter, TypeScript validity), classify, produce structured report, and drive the 3-cycle retry loop.
- **`generate.md` Step 10 — Bootstrap `tasks-auditor` Squad agent.** Every run of `speckit.sdd-orchestrator.generate` now ensures the `tasks-auditor` agent exists in `.squad/agents/`. If absent, it is created from the agent template with `status: active`, `model_tier: proficient`, `domain: audit/qa`.
- **`ceremonies-tasks-auditor.md` Squad agent requirement directive.** Documents that `tasks-auditor` must exist in `.squad/agents/` before the ceremony runs, and that the coordinator must trigger `generate` to bootstrap it if absent.
- **RULE-017** added to `Multi-Agent SDD Orchestrator.md`: after every implementation batch, `tasks-auditor` must verify all tasks before the workflow is considered complete.
- **`Multi-Agent SDD Orchestrator.md` updated** to reflect all current phases (-1 through 7), hooks, workflow diagram, Phase 7 section, and updated Success Criteria.

## [1.4.0] - 2026-06-02

### Added

- **`speckit.sdd-orchestrator.api-contract` command.** Detects API-impacting tasks in `tasks.md` (new routes, request/response contract changes, DTO/swagger/openapi updates) and scaffolds `API.md` from the squad template. Assigns endpoint ownership from routing annotations. Runs as a no-op when no API impact is detected.
- **`speckit.sdd-orchestrator.after-tasks` orchestrator command.** Replaces the single-step `after_tasks` hook with a two-step pipeline: Phase 5 routing (`speckit.sdd-orchestrator.route`) followed by API contract detection (`speckit.sdd-orchestrator.api-contract`). Both steps share the same task-load pass; routing annotations written in Step 1 inform ownership assignment in Step 2.
- **`after_tasks` hook now points to `speckit.sdd-orchestrator.after-tasks`** instead of `speckit.sdd-orchestrator.route` directly.

## [1.3.1] - 2026-06-02

### Fixed

- **`/speckit.sdd-orchestrator.init` agora executa o `sdd-init.sh` completo.** O command body anterior descrevia o comportamento como prosa de documentação — o modelo lia como "o que este comando faz", não como "o que você deve fazer agora", e por isso não rodava o script nem atualizava o `copilot-instructions.md`. Reescrito com passos imperativos e `bash .specify/extensions/sdd-orchestrator/scripts/sdd-init.sh` como passo central explícito. Também corrigido o path do script (era `.specify/scripts/sdd-init.sh` — inexistente).

## [1.3.0] - 2026-06-02

### Fixed

- **`sdd-init.sh` agora atualiza o bloco `copilot-instructions.md` em re-runs.** Anteriormente, ao detectar o marcador `<!-- SPECKIT-ORCHESTRATOR START -->` existente, o script pulava silenciosamente — o conteúdo nunca era atualizado ao reinstalar. Agora substitui o bloco entre as tags via Python (in-place, sem duplicação), garantindo que upgrades da extensão propaguem as instruções mais recentes.
- **`route.md` agora atualiza `.squad/routing.md`** com os padrões de keyword → agent inferidos do batch de tasks atual, alinhando ao comportamento do `spec-kit-squad` de referência. Também corrigido o output e o `→Next` para `speckit.sdd-orchestrator.implement`.
- **`generate.md` agora atualiza `.github/copilot-instructions.md`** via marcadores HTML (passo 10), espelhando o comportamento da referência. Assim, quando o `after_specify` hook dispara o generate, as instruções do projeto ficam em sincronia com a extensão instalada.
- Corrigida referência de `→Next` no agent `route` (`/sdd.implement` → `/speckit.sdd-orchestrator.implement`).

## [1.2.0] - 2026-06-01

### Fixed

- **Orchestrator agents no longer abandon the pipeline in VS Code Copilot Chat.** The `speckit.sdd-orchestrator.specify` agent used `Spawn:` directives and instructions to "invoke the global `specify` CLI" — neither is a VS Code Chat primitive, so the model concluded it was in the wrong environment and fell back to editing code directly. Rewrote the agent to run every phase **inline** (no `Spawn:`, no CLI dependency) and to chain registered commands/hooks via `EXECUTE_COMMAND:` markers, matching the stock `speckit.specify` pattern that works in VS Code.
- **Fixed misleading agent descriptions.** `speckit.sdd-orchestrator.specify` / `.implement` described themselves as "Intercepts/REPLACES the stock command", confusing the model about its own role when invoked directly. Descriptions are now imperative action statements.
- Added an explicit anti-fallback rule: the specify agent produces a specification only and must STOP and report on failure rather than editing code.

### Added

- **Phase 1.5 — Brainstorm.** The specify pipeline now runs the `superpowers:brainstorming` skill after discovery, producing `brainstorm.md`. The authoritative `spec.md` is enriched by `brainstorm.md` + `discovery.md` + `architecture-analysis.md` (discovery and brainstorm are complementary).

## [1.1.0] - 2026-06-01

### Fixed

- **Orchestrated commands are now real Spec-Kit commands.** Registered `speckit.sdd-orchestrator.specify`, `.implement`, `.codebase-index`, `.codebase-architect`, `.discovery`, and `.route` in `provides.commands`. Previously these existed only as prose in `copilot-instructions.md` and as prompt files, so the runtime had no command to dispatch and the SDD pipeline ran inconsistently (or not at all).
- **Removed the non-functional `/speckit.specify` "override".** Spec-Kit cannot rewrite a built-in slash command; the override was advisory text the agent obeyed unreliably. Users now run `/speckit.sdd-orchestrator.specify` and `/speckit.sdd-orchestrator.implement` directly as the orchestrated entry points.
- **Fixed invalid command names.** `codebase.index`/`codebase.architect` (four dot-segments) violated the `speckit.<id>.<command>` schema; renamed to `codebase-index`/`codebase-architect`, along with their agent and prompt files, so command → agent resolution is 1:1.
- Updated all `Spawn:` references in the orchestrator agents to the registered command names.

### Changed

- Raised the Spec Kit requirement to `>=0.8.18`. Earlier versions do not wire `before_specify`/`after_specify` hooks into the specify command template (see spec-kit PR #1886), so the `after_specify` hook would silently no-op.

## [1.0.4] - 2026-06-01

### Fixed

- Ensure `.github/copilot-instructions.md` is created or appended with SDD Orchestrator instructions when installing the extension
- Copy prompt templates from `templates/prompts` into `.github/prompts`

## [1.0.1] - 2026-06-01

### Fixed

- Correct command naming to `speckit.sdd-orchestrator.*` so the extension passes Spec-Kit installation validation

## [1.0.0] - 2026-06-01

### Added

- Initial release of the `sdd-orchestrator` Spec Kit extension
- Added custom SDD workflow agent definitions in `.github/agents`
- Configured `after_tasks` hook to run `sdd.route`
- Added integration documentation and extension manifest
