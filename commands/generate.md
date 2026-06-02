---
description: "Re-generate Squad agent definitions as your spec evolves"
---

# Squad Bridge: Generate

Re-read the current spec and regenerate Squad agent definitions, capabilities,
and routing rules to stay in sync with spec changes. Safe to run repeatedly —
existing agents are updated in place; agents no longer supported by the spec
are flagged (not deleted).

This command is also triggered by the `after_specify` hook.

## User Input

$ARGUMENTS

## Steps

1. **Verify `.squad/` exists** — if not, tell the user to run
   `/speckit.sdd-orchestrator.init` first and stop.

2. **Read the spec** from the active feature directory (read
   `.specify/feature.json` → `feature_directory`; fall back to the most
   recently modified directory under `specs/`).

3. **Read existing agents** from `.squad/agents/` (each agent lives in
   `.squad/agents/{name}/charter.md`) so changes can be diffed rather than
   blindly overwritten.

4. **Analyze the spec** to extract technology domains, architectural concerns,
   and cross-cutting roles. If `$ARGUMENTS` names a specific domain, limit
   regeneration to that domain's agent.

5. **Diff against existing agents**:
   - **New domains** found in spec but no matching agent → create new agent
   - **Changed domains** (different prominence or tech stack) → update agent
     capabilities and model tier
   - **Removed domains** (in existing agents but absent from new spec) →
     set `status: inactive` and note in output (do NOT delete)

6. **Update `.squad/team.md` and `.squad/routing.md`** to reflect the new
   agent set, routing rules, and model tier assignments. In markdown-first mode,
   keep the root `.squad` artifacts authoritative and do not require a
   `squad.config.ts` file.

7. **Update `.squad/routing.md`** to add routing rules for any new agents and
   update patterns for changed agents.

8. **Install `list-hooks.sh`** — copy
   `.specify/extensions/sdd-orchestrator/scripts/bash/list-hooks.sh` to
   `.specify/scripts/bash/list-hooks.sh` and make it executable (`chmod +x`).
   Overwrite if it already exists (always keep the latest version from the
   extension bundle).

   Print: `✅ Script installed: .specify/scripts/bash/list-hooks.sh`

9. **Bootstrap `.squad/ceremonies.md`** — check whether it already contains
   the heading `## Speckit Tasks Audit`.

   - **Heading absent** → append the contents of
     `.specify/extensions/sdd-orchestrator/templates/ceremonies-tasks-auditor.md`.
     Print: `✅ ceremonies.md patched with Speckit Tasks Audit ceremony`
   - **Heading present** → skip silently.
     Print: `ℹ️  ceremonies.md already contains Speckit Tasks Audit — skipping`

   If `.squad/ceremonies.md` does not exist, create it with the template
   content. Print: `✅ ceremonies.md created with Speckit Tasks Audit ceremony`

10. **Update `.github/copilot-instructions.md`** — apply the two SDD Orchestrator
    blocks using their HTML comment markers as boundaries, replacing the block
    content if the markers are present, or appending if they are not:

    - `<!-- SPECKIT-ORCHESTRATOR START -->` … `<!-- SPECKIT-ORCHESTRATOR END -->`
    - `<!-- SPECKIT HOOKS -->` … `<!-- END SPECKIT HOOKS -->`

    Source: `.specify/extensions/sdd-orchestrator/templates/copilot-instructions.md`

    This ensures the installed project always has the latest orchestration
    instructions, including the current pipeline phases, entry-point commands,
    and hook protocol.

    Print: `✅ .github/copilot-instructions.md updated with SDD Orchestrator blocks`

11. **Print a diff summary**:

    ```
    Squad agents updated
      ✅ Added   : data-engineer (PostgreSQL/migrations — proficient)
      ✏️  Updated : backend-engineer (added GraphQL capability)
      ⚠️  Inactive: mobile-engineer (no longer in spec — set to inactive)

    Routing rules updated: 8 total (2 added, 1 modified)
    ```

## Notes

- `inactive` agents remain in `.squad/` and can be reactivated manually with
  `squad` commands if needed.
- If the spec has not changed since the last run, this command reports
  "No changes detected" and exits cleanly.
