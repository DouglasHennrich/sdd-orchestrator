## Speckit Tasks Audit

| Field | Value |
|-------|-------|
| **Trigger** | auto |
| **When** | after |
| **Condition** | speckit implementation batch completed — any of: `speckit.implement` agent finishes, all tasks in a phase are marked done, or user says "implementation complete" / "finished implementing" / "done with tasks" |
| **Facilitator** | tasks-auditor |
| **Participants** | tasks-auditor only (reports back to coordinator) |
| **Time budget** | focused |
| **Enabled** | ✅ yes |

**Agenda:**
1. Read `.specify/feature.json` → resolve active `feature_directory`
2. Load `{feature_directory}/tasks.md` as the source of truth
3. For each task: verify file existence, Result pattern, ZodValidationPipe, Presenter usage, TypeScript validity
4. Classify every task: `✅ done`, `⚠️ partial`, `❌ missing`, `🔴 broken`
5. Produce structured audit report (see tasks-auditor charter for format)
6. Return report to coordinator with routing suggestions for all non-passing tasks

**Coordinator integration:**
After any speckit implementation batch (phase or full run), automatically spawn `tasks-auditor` in sync mode. If the report contains non-`✅ done` tasks, re-route each failing task to the responsible agent without waiting for user input. Repeat until all tasks pass or coordinator escalates to user after 3 retry cycles.
