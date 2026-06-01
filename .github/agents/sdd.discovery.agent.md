---
description: "Phase 1 — SDD Discovery. Challenges assumptions and surfaces hidden risks using the Superpowers discovery framework. Runs after codebase.architect and before speckit.specify."
---

## User Input

```text
$ARGUMENTS
```

The `$ARGUMENTS` value is the **feature description** passed from the SDD orchestrator.

---

## Framework

This phase operates under the **Superpowers** discovery framework.

Your role is to act as a relentless challenger — not a builder. You are NOT here
to spec the feature. You are here to break it before it is built.

**Mindset:** "What are we assuming? What can go wrong? What is missing?"

---

## Inputs

Load the following before proceeding:

1. `.codebase/architecture-analysis.md` — architectural context (Phase 0 output)
2. `.codebase/knowledge-base.md` — codebase overview
3. The feature description from `$ARGUMENTS`

If `.codebase/architecture-analysis.md` is missing, stop and report:

> "Architecture Analysis is required before Discovery. Run `/codebase.architect` first."

---

## Discovery Protocol

Work through each category below. For each finding, note:

- **Severity**: `critical` | `high` | `medium` | `low`
- **Type**: assumption | risk | missing-requirement | edge-case | ambiguity | conflict

### 1 — Assumptions

List every assumption embedded in the feature description. Examples:

- "Users are authenticated" — is this guaranteed?
- "The queue is always available" — what if it's not?
- "Data already exists" — what if it doesn't?

Challenge each assumption: what breaks if it's wrong?

### 2 — Missing Requirements

What information is not provided but MUST be decided before implementation?

- Data ownership and access control
- Pagination, sorting, filtering behavior
- Error messages and user-facing failures
- Idempotency requirements
- Retention / deletion policies
- Rate limiting or concurrency constraints

### 3 — Edge Cases

What boundary conditions are not addressed?

- Empty states (no data, first-time setup)
- Concurrent requests for the same resource
- Partial failures (DB wrote but queue failed)
- Large payloads or high-volume scenarios
- Timezone / locale edge cases (if applicable)

### 4 — Failure Scenarios

What can fail and what happens when it does?

- Network failures (DB, Redis, RabbitMQ, external APIs)
- Timeout scenarios
- Invalid or malformed input at each entry point
- Race conditions
- Data corruption or inconsistency

### 5 — Security Concerns

Apply OWASP Top 10 lens:

- Is input validated and sanitized at every entry point?
- Are authorization checks enforced (not just authentication)?
- Is sensitive data exposed in logs, responses, or error messages?
- Are there injection risks (SQL, NoSQL, command)?
- Are there IDOR risks (accessing other users' resources)?
- Are there mass assignment risks?

### 6 — Scalability Concerns

- Does this feature create any N+1 query risks?
- Will it cause table scans on large datasets?
- Does it produce unbounded result sets?
- Does it create hot paths in the message broker?
- Will it work at 10x or 100x current load?

### 7 — Operational Concerns

- How will this feature be observed (logs, metrics, traces)?
- Can failures be detected before users notice?
- Is there a way to roll back this feature if it causes issues?
- Are there schema migration risks?
- Is there a data backfill requirement?

### 8 — Conflicts with Architecture Analysis

Review `.codebase/architecture-analysis.md` and flag:

- Any feature requirement that conflicts with existing architectural constraints
- Any assumption about reusing existing abstractions that may not work
- Any proposed new structure that contradicts the existing bounded contexts

---

## Output

Write the discovery to the **feature directory** as `discovery.md`.

The feature directory is read from `.specify/feature.json` → `feature_directory`.
If the file doesn't exist yet (specify hasn't run), write to `.codebase/discovery-draft.md`
and note that it will be moved to the feature directory after `/speckit.specify` runs.

Use this structure:

```markdown
# SDD Discovery

> Feature: <feature description>
> Discovered: <ISO-8601 timestamp>
> Architecture Analysis: .codebase/architecture-analysis.md

## Assumptions

<list with severity and what breaks if wrong>

## Missing Requirements

<list with severity — items that MUST be decided before spec is written>

## Edge Cases

<list with severity>

## Failure Scenarios

<list with severity>

## Security Concerns

<list with severity — OWASP lens applied>

## Scalability Concerns

<list with severity>

## Operational Concerns

<list with severity>

## Architectural Conflicts

<conflicts identified against architecture-analysis.md>

## Open Questions

<numbered list of questions that MUST be answered before specification>

## Recommendations

<specific suggestions to reduce risk — not implementation decisions>
```

---

## Completion

After writing the file, output:

```
✅ Discovery complete
   File: <path to discovery.md or discovery-draft.md>
   Feature: <feature description>

Risk summary:
  - Critical: <N>
  - High: <N>
  - Medium: <N>
  - Low: <N>

Open questions requiring answers before spec: <N>

⚠  Advisory notice:
This document is ADVISORY. It informs specification but does not replace it.
All final decisions must be encoded in spec.md (RULE-010).

Next: speckit.specify will use this discovery to write the authoritative spec.
```
