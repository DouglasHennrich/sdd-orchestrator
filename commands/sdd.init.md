---
name: "speckit.sdd-orchestrator.init"
description: "Initialize the SDD Orchestrator integration: copies agents, prompts, and updates copilot-instructions.md."
---

# SDD Orchestrator — Init

Initialize or update the `sdd-orchestrator` extension assets in the current
Spec-Kit project.

## Steps

Run the initialization script:

```bash
bash .specify/extensions/sdd-orchestrator/scripts/sdd-init.sh
```

This script performs all initialization steps:

1. Copies all agent definitions from the extension into `.github/agents/`
2. Copies all prompt templates from the extension into `.github/prompts/`
3. Creates or **updates** `.github/copilot-instructions.md` — if the SDD
   Orchestrator blocks are already present, the script replaces them in-place
   with the latest content; otherwise appends them. This means re-running
   `/speckit.sdd-orchestrator.init` after an extension upgrade will always
   propagate the updated instructions.
4. Initializes `.squad/` via `squad init` if it does not exist yet.
5. Ensures the `Multi-Agent SDD Orchestrator.md` documentation is present in
   the installed extension directory.

After the script completes, report what was done:

- How many agents were copied
- Whether `copilot-instructions.md` was created, appended, or updated in-place
- Whether `.squad/` was initialized or already existed

If the script fails, show the error output and tell the user to check that the
extension is installed at `.specify/extensions/sdd-orchestrator/`.
