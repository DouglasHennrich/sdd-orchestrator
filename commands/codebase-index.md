---
description: "Phase -1 — build or refresh the repository knowledge graph (.codebase/graph.json + knowledge-base.md)."
---

## User Input

```text
$ARGUMENTS
```

---

## Purpose

Build a persistent, token-efficient knowledge graph of the repository so that
subsequent phases (Architect, Discovery, Specification) can load a compact
summary instead of re-scanning the entire monorepo from scratch.

> This command is normally invoked automatically by `speckit.sdd-orchestrator.specify` (Phase -1),
> but can be run standalone to refresh the knowledge base.

---

## Staleness Check

Before doing any scanning, check if a refresh is actually needed:

1. Read `.codebase/graph.json` (if it exists) and inspect the `generated_at` field.
2. Check the git log for changes since `generated_at` to any of the following
   **sentinel paths** (use `git log --since="<generated_at>" -- <paths>` or compare
   modification times):
   - `**/package.json`
   - `**/pnpm-workspace.yaml`
   - `**/*.entity.ts`
   - `**/schema.prisma` or `**/*.prisma`
   - `**/migrations/**`
   - `**/*.module.ts`
   - `**/rabbitmq*.ts` or `**/messaging/**`
   - `**/*.controller.ts`
   - `**/tsconfig*.json`
   - `.github/agents/**`

3. If the graph is **less than 24 hours old** AND no sentinel files changed,
   output:

   ```
   ✓ Knowledge base is fresh (generated_at: <timestamp>). Skipping re-index.
   ```

   Then stop — do not re-scan.

4. If the graph is **missing or stale**, proceed with the full scan below.

---

## Scan Protocol

Scan the repository and collect the following signals. Work top-down from the
workspace root. Prefer reading `package.json` / `pnpm-workspace.yaml` first to
discover workspace packages before diving into source trees.

### 1 — Workspace Structure

- List all workspace packages (monorepo roots, `packages/*`, `apps/*`, etc.)
- For each package capture: `name`, `type` (backend/frontend/lib/infra), `path`,
  key dependencies from `package.json`

### 2 — Modules & Bounded Contexts

- Identify NestJS modules (`*.module.ts`) — capture module name, imports,
  exports, providers
- Identify React app entry points and major route groups
- For each module note: domain, layer (application/domain/infra), and package

### 3 — Data Layer

- Database entities (`*.entity.ts`, Prisma schemas)
- Tables: name, key columns, relations, indexes
- Migrations: latest migration name and date

### 4 — API Surface

- NestJS controllers: path prefix, HTTP methods, auth requirements
- tRPC routers (if any): router name, procedures
- GraphQL schemas (if any): type names

### 5 — Messaging / Events

- RabbitMQ exchanges and queue names (from decorators or config files)
- BullMQ queues (queue names, job types)
- Event contracts (DTOs used in message payloads)

### 6 — Shared Abstractions

- Abstract base classes, generic repositories, base services
- Shared DTOs, validators, decorators
- Common utilities and helper modules

### 7 — Conventions

- Naming patterns (file naming, class naming, directory structure)
- Auth strategy (JWT, guards, decorators used)
- Error handling pattern (Result type, exceptions, filters)
- Testing conventions (Jest config, test file locations, factory patterns)
- ORM conventions (TypeORM / Prisma, migration tool)

### 8 — Infrastructure

- Docker services (from `docker-compose.yml` or similar)
- Environment variables (from `.env.example`)
- CI/CD pipeline steps (from `.github/workflows/`)

---

## Output Format

### `.codebase/graph.json`

Write a structured JSON graph:

```json
{
  "generated_at": "<ISO-8601 timestamp>",
  "project": "<project name>",
  "packages": [
    {
      "name": "string",
      "type": "backend|frontend|lib|infra",
      "path": "string",
      "framework": "string",
      "key_deps": ["string"]
    }
  ],
  "modules": [
    {
      "name": "string",
      "package": "string",
      "domain": "string",
      "layer": "application|domain|infrastructure",
      "imports": ["string"],
      "exports": ["string"],
      "providers": ["string"]
    }
  ],
  "entities": [
    {
      "name": "string",
      "table": "string",
      "package": "string",
      "columns": ["string"],
      "relations": ["string"]
    }
  ],
  "api_surface": [
    {
      "controller": "string",
      "package": "string",
      "base_path": "string",
      "endpoints": [{ "method": "string", "path": "string", "auth": "boolean" }]
    }
  ],
  "messaging": [
    {
      "type": "rabbitmq|bullmq|event",
      "name": "string",
      "package": "string",
      "producers": ["string"],
      "consumers": ["string"]
    }
  ],
  "conventions": {
    "naming": "string",
    "auth_strategy": "string",
    "error_handling": "string",
    "testing": "string",
    "orm": "string"
  },
  "infrastructure": {
    "docker_services": ["string"],
    "env_vars": ["string"]
  }
}
```

### `.codebase/knowledge-base.md`

Write a human-readable narrative summary structured as:

```markdown
# Repository Knowledge Base

> Generated: <timestamp> | Project: <name>

## Workspace Structure

<brief description of packages and their roles>

## Domain Boundaries

<modules grouped by domain with one-line descriptions>

## Data Layer

<tables and key relationships in plain language>

## API Surface

<controllers and endpoint groups>

## Messaging / Events

<exchanges, queues, and event types>

## Shared Abstractions

<base classes, common patterns>

## Conventions

<naming, auth, error handling, testing, ORM>

## Infrastructure

<docker services, key env vars>

## ⚠ Known Complexity / Technical Debt

<anything that looks incomplete, inconsistent, or potentially confusing for a new feature>
```

---

## Completion

After writing both files, output:

```
✅ Knowledge base built
   Generated: <timestamp>
   Packages: <N>
   Modules: <N>
   Entities: <N>
   Controllers: <N>
   Queues/Exchanges: <N>

Files written:
  .codebase/graph.json
  .codebase/knowledge-base.md

Next: speckit.sdd-orchestrator.codebase-architect will use these artifacts for Phase 0.
```
