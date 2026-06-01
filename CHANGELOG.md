# Changelog

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
