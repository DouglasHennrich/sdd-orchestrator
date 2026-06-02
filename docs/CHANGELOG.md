# Changelog

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

- **`/speckit.sdd-orchestrator.init` agora executa o `sdd-init.sh` completo.** O command body anterior descrevia o comportamento como prosa de documentação — o modelo lia como "o que este comando faz", não como "o que você deve fazer agora". Reescrito com passos imperativos e path correto do script.

## [1.3.0] - 2026-06-02

### Fixed

- **`sdd-init.sh` agora atualiza o bloco `copilot-instructions.md` em re-runs.** Anteriormente, ao detectar o marcador `<!-- SPECKIT-ORCHESTRATOR START -->` existente, o script pulava silenciosamente — o conteúdo nunca era atualizado ao reinstalar. Agora substitui o bloco entre as tags via Python (in-place, sem duplicação), garantindo que upgrades da extensão propaguem as instruções mais recentes.
- **`route.md` agora atualiza `.squad/routing.md`** com os padrões de keyword → agent inferidos do batch de tasks atual, alinhando ao comportamento do `spec-kit-squad` de referência.
- **`generate.md` agora atualiza `.github/copilot-instructions.md`** via marcadores HTML (passo 10), espelhando o comportamento da referência.
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

## [1.0.1] - 2026-06-01

### Fixed

- Correct command naming to `speckit.sdd-orchestrator.*` so the extension passes Spec-Kit installation validation

## [1.0.0] - 2026-06-01

### Added

- Initial release of the `sdd-orchestrator` Spec Kit extension
- Added custom SDD workflow agent definitions in `.github/agents`
- Configured `after_tasks` hook to run `sdd.route`
- Added integration documentation and extension manifest
