# sdd-orchestrator

`SDD Orchestrator for Spec-kit + Squad + Superpowers` is a Spec Kit extension designed to bind Spec-Kit workflows with Squad specialist agents and the Superpowers agent framework.

- [Spec-kit](https://github.com/github/spec-kit)
- [Squad](https://github.com/bradygaster/squad)
- [Superpowers](https://github.com/obra/superpowers)


## What it does

- Adds `.github/agents` definitions for custom SDD routing and execution agents
- Configures an `after_tasks` hook that runs `sdd.route` after `/speckit.tasks`
- Enables task annotation with `→AgentName` for specialist agent execution
- Integrates Spec-Kit, Squad, and Superpowers workflows in a single orchestrated extension

## Requirements

- Spec Kit `>=0.8.18` (earlier versions do not wire `before_specify`/`after_specify` hooks into the specify command template, so the SDD hooks would silently no-op)
- `@bradygaster/squad-cli` `>=0.9.4`
- `superpowers`

## Installation

Install this extension locally for testing:

```bash
specify extension add --dev /path/to/sdd-orchestrator
```

For published releases, install from the release archive URL:

```bash
specify extension add sdd-orchestrator --from https://github.com/DouglasHennrich/sdd-orchestrator/archive/refs/tags/v1.1.0.zip
```

## Usage

After installing the extension, your project will use the custom `after_tasks` hook to annotate `tasks.md` with `→AgentName` assignments.

### Initialize SDD Orchestrator assets

Run the command below to copy the agent definitions into your project's `.github/agents` folder, bootstrap Squad if needed, and ensure the orchestration documentation is available in the installed extension directory:

```bash
/speckit.sdd-orchestrator.init
```

### Run the orchestrated workflow

Spec-Kit cannot literally rewrite what `/speckit.specify` does — a slash command
always runs its own registered template. To get the SDD pipeline, run the
**orchestrated** commands this extension registers instead of the stock ones:

| Instead of…          | Run…                                  |
| -------------------- | ------------------------------------- |
| `/speckit.specify`   | `/speckit.sdd-orchestrator.specify`   |
| `/speckit.implement` | `/speckit.sdd-orchestrator.implement` |

`/speckit.sdd-orchestrator.specify` orchestrates the full pipeline:

```
Phase -1  speckit.sdd-orchestrator.codebase-index      → .codebase/graph.json + knowledge-base.md
Phase  0  speckit.sdd-orchestrator.codebase-architect  → .codebase/architecture-analysis.md
Phase  1  speckit.sdd-orchestrator.discovery           → <feature_dir>/discovery.md
Phase  2  speckit.specify (stock)                      → <feature_dir>/spec.md   ← authoritative
```

It then fires the `after_specify` hook to keep Squad agents aligned.

### Regenerate Squad agents after spec changes

When `specify speckit.sdd-orchestrator.specify` completes, the extension runs `speckit.sdd-orchestrator.generate` via the `after_specify` hook to keep Squad agent definitions and routing aligned with the latest spec.

**Important:** Use the global `specify` CLI installation to launch the orchestrator and hooks. Avoid calling a local `speckit` binary directly, because the global `specify` binary is required to resolve `.specify/extensions.yml` hooks correctly.

If you need to run the script directly:

```bash
bash .specify/extensions/sdd-orchestrator/scripts/sdd-init.sh
```

Keep the `.github/agents` folder synchronized with the extension whenever you update specialist routing or execution policies.

## Changelog

The release history is available in both `CHANGELOG.md` and `docs/CHANGELOG.md`.

## License

MIT
