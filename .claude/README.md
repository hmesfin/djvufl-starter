# .claude/ — App Planning System

This directory holds the **planning** layer for the djvufl starter: an
interactive command and a set of templates that turn an app idea into a
concrete, TDD-driven implementation plan.

## What's here

- **`commands/plan-app.md`** — `/plan-app`: interactive discovery that produces
  a technical requirements doc + phased project plan.
- **`PLANNING_GUIDE.md`** — how the planning system works, philosophy, and
  advanced usage.
- **`templates/`** — worked example specs (REQUIREMENTS / PROJECT_PLAN) for
  blog, ecommerce, saas, social, and project-management apps.
- **`references/PROJECT_STRUCTURE.md`** — canonical project layout.

## Usage

```bash
/plan-app
```

Claude asks about your app, then generates a plan under `project-plans/`. See
`PLANNING_GUIDE.md` for the full workflow.

> The autonomous **execution** harness that consumes these plans (builder
> agents, orchestrators, `/execute-*` commands) is maintained separately and is
> not part of this public starter.
