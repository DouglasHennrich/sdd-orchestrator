# Changelog

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
