# Multi-Agent SDD Orchestrator

## Objective

Build a workflow orchestrator that combines:

* Spec-Kit
* Squad
* Superpowers

while maintaining strict separation of responsibilities and a single source of truth.

The objective is to create a complete Spec-Driven Development workflow capable of:

1. Understanding the existing codebase
2. Discovering requirements
3. Identifying ambiguities
4. Detecting architectural conflicts
5. Generating specifications
6. Generating implementation plans
7. Generating tasks
8. Routing tasks to specialized agents
9. Executing tasks using Subagent Driven Development
10. Executing implementation through Test Driven Development

---

# Architectural Principles

## Single Source of Truth

Spec-Kit artifacts are the only authoritative artifacts.

Authoritative files:

* spec.md
* plan.md
* tasks.md

Non-authoritative files:

* architecture-analysis.md
* discovery.md
* brainstorm.md

These files are advisory only.

Execution agents must never make implementation decisions based solely on advisory artifacts.

All final decisions must exist inside Spec-Kit artifacts.

---

## Separation of Responsibilities

### Codebase Architect

Responsible for understanding the existing system.

### Superpowers

Responsible for discovery, investigation, questioning assumptions, and uncovering hidden risks.

### Spec-Kit

Responsible for specification, planning, and task generation.

### Squad

Responsible for orchestration and execution.

---

# Workflow

```text
User Request
        ↓
Codebase Architect
        ↓
architecture-analysis.md
        ↓
Superpowers Discovery
        ↓
discovery.md
        ↓
Spec-Kit Specify
        ↓
spec.md
        ↓
Spec-Kit Plan
        ↓
plan.md
        ↓
Spec-Kit Tasks
        ↓
tasks.md
        ↓
Squad Routing
        ↓
task-routing.yaml
        ↓
Squad Execution
        ↓
Implementation
```

---

# Phase 0 - Codebase Architecture Analysis

Trigger:

/speckit.specify

Before any discovery or specification process begins, execute a mandatory Codebase Architect phase.

Purpose:

Understand the existing codebase before discussing implementation.

Responsibilities:

* Read the repository structure
* Identify architectural patterns
* Identify existing modules
* Identify existing services
* Identify shared abstractions
* Identify bounded contexts
* Identify domain boundaries
* Identify naming conventions
* Identify coding standards
* Identify infrastructure standards
* Detect duplicated responsibilities
* Detect overlapping modules
* Detect existing implementations that solve similar problems
* Detect framework conventions
* Detect technical debt relevant to the feature
* Detect integration points
* Detect hidden dependencies

Required Questions:

* Does this feature already partially exist?
* Is there already a module responsible for this domain?
* Which existing abstractions should be reused?
* Which existing patterns must be respected?
* What architectural constraints already exist?
* What implementation approaches would violate current architecture?

Output:

architecture-analysis.md

Example Structure:

# Existing Architecture

# Related Modules

# Existing Patterns

# Existing Abstractions

# Potential Conflicts

# Reuse Opportunities

# Architectural Constraints

---

# Phase 1 - Discovery

Trigger:

Automatically after Architecture Analysis.

Framework:

Superpowers

Purpose:

Challenge assumptions and improve requirement quality before specification begins.

Inputs:

* User request
* architecture-analysis.md

Responsibilities:

* Challenge assumptions
* Detect missing requirements
* Detect edge cases
* Detect failure scenarios
* Detect scalability concerns
* Detect security concerns
* Detect operational concerns
* Detect monitoring concerns
* Detect observability concerns
* Detect hidden complexity
* Generate clarification questions
* Detect contradictions
* Detect domain inconsistencies
* Detect implementation risks

Required Questions:

* What assumptions are being made?
* What can fail?
* What is ambiguous?
* What information is missing?
* What security risks exist?
* What scalability risks exist?
* What operational risks exist?
* What edge cases have not been considered?

Output:

discovery.md

Example Structure:

# Assumptions

# Risks

# Open Questions

# Edge Cases

# Failure Scenarios

# Security Concerns

# Scalability Concerns

# Recommendations

---

# Phase 2 - Specification

Trigger:

After Discovery completes.

Framework:

Spec-Kit

Inputs:

* User request
* architecture-analysis.md
* discovery.md

Output:

spec.md

Rules:

* Spec-Kit owns specification generation.
* Discovery artifacts are advisory.
* Architecture artifacts are advisory.
* spec.md becomes the authoritative definition.

Example Contents:

* Functional Requirements
* Non-Functional Requirements
* Acceptance Criteria
* Business Rules
* Constraints
* Dependencies

---

# Phase 3 - Planning

Trigger:

/speckit.plan

Framework:

Spec-Kit

Input:

* spec.md

Output:

plan.md

Rules:

* Planning is exclusively owned by Spec-Kit.
* No other framework may generate implementation plans.

Example Contents:

* Technical Design
* Implementation Strategy
* Rollout Strategy
* Migration Strategy
* Risks
* Dependencies

---

# Phase 4 - Task Generation

Trigger:

/speckit.tasks

Framework:

Spec-Kit

Inputs:

* spec.md
* plan.md

Output:

tasks.md

Rules:

* Tasks are generated only by Spec-Kit.
* No execution agent may generate new tasks.
* No execution agent may modify tasks.

Task Requirements:

Each task must contain:

* Unique ID
* Description
* Acceptance Criteria
* Dependencies
* Estimated Complexity
* Suggested Owner Type

---

# Phase 5 - Task Routing

Trigger:

Immediately after tasks.md generation.

Framework:

Squad

Inputs:

* spec.md
* plan.md
* tasks.md

Purpose:

Assign ownership.

Responsibilities:

* Classify tasks
* Route tasks
* Balance workload
* Identify execution dependencies

Output:

task-routing.yaml

Example:

tasks:
TASK-001:
owner: backend-agent

TASK-002:
owner: database-agent

TASK-003:
owner: qa-agent

TASK-004:
owner: infra-agent

Rules:

* Squad may assign tasks.
* Squad may not rewrite tasks.
* Squad may not create tasks.
* Squad may not modify specifications.

---

# Phase 6 - Execution

Trigger:

/speckit.implement

Framework:

Squad

Purpose:

Execute routed work.

Inputs:

* spec.md
* plan.md
* tasks.md
* task-routing.yaml

Squad becomes the execution orchestrator.

---

# Execution Agents

Supported agents:

* backend-agent
* database-agent
* infra-agent
* security-agent
* qa-agent
* reviewer-agent

Additional agents may be added later.

---

# Mandatory Agent Behaviors

All execution agents must inherit Superpowers execution behaviors.

Mandatory capabilities:

* subagent-driven-development
* test-driven-development

---

# Mandatory Test Driven Development

Every implementation must follow:

1. Write tests
2. Execute tests
3. Confirm failure
4. Implement solution
5. Execute tests
6. Refactor
7. Execute tests again

Implementation without tests is forbidden.

---

# Mandatory Subagent Driven Development

Agents must delegate work whenever specialization is beneficial.

Examples:

Backend Agent
→ Database Agent

Backend Agent
→ Security Agent

Backend Agent
→ QA Agent

Infra Agent
→ Security Agent

Reviewer Agent
→ QA Agent

Large tasks must be decomposed into specialized work.

---

# Hard Constraints

RULE-001

Spec-Kit artifacts are the only authoritative artifacts.

RULE-002

Architecture Analysis must always execute before Discovery.

RULE-003

Discovery must always execute before Specification.

RULE-004

Specification must always execute before Planning.

RULE-005

Planning must always execute before Task Generation.

RULE-006

Task Generation must always execute before Routing.

RULE-007

Routing must always execute before Implementation.

RULE-008

Squad may route tasks but may not modify tasks.

RULE-009

Execution agents may implement tasks but may not redefine requirements.

RULE-010

Discovery artifacts may enrich specifications but may not replace specifications.

RULE-011

Architecture Analysis artifacts may enrich specifications but may not replace specifications.

RULE-012

All implementation must follow Test Driven Development.

RULE-013

All execution agents must support Subagent Driven Development.

RULE-014

No implementation may begin before routing is completed.

RULE-015

Codebase Architect findings must be considered before any specification is generated.

RULE-016

No agent may bypass any workflow phase.

---

# Success Criteria

A successful workflow must produce:

* architecture-analysis.md
* discovery.md
* spec.md
* plan.md
* tasks.md
* task-routing.yaml

and a fully implemented feature following:

* Architecture-Aware Development
* Spec Driven Development
* Test Driven Development
* Subagent Driven Development
* Multi-Agent Execution

while preserving a single source of truth and strict separation of responsibilities.
