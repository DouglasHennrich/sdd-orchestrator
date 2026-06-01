---
name: "speckit.sdd-orchestrator.init"
description: "Initialize the SDD Orchestrator integration by copying agent definitions and documentation into the project."
---

## Purpose

Initialize the `sdd-orchestrator` extension for the current Spec-Kit project.

## Behavior

This command performs the following initialization steps:

1. Ensure the project has a `.squad/` folder. If it does not exist, the command bootstraps Squad directly by running `squad init`.
2. Copy all agent definition files from the extension package's `templates/agents/` into the project's own `.github/agents/`.
3. Ensure the `Multi-Agent SDD Orchestrator.md` documentation is present inside the installed extension directory.

## Usage

```bash
/speckit.sdd-orchestrator.init
```

The command is responsible for both:

- bootstrapping Squad when `.squad/` is missing
- installing the SDD agent assets and documentation

If you need to run the installation manually, use:

```bash
bash scripts/sdd-init.sh
```
