# AGENTS.md - Agent Guidelines for DjVuFL Starter

This file provides build/lint/test commands and code style guidelines for agentic coding in this Django + Vue.js + Flutter repository.

## Build/Lint/Test Commands

### Backend (Django)

All Django commands MUST run via Docker containers (except `startapp`):

```bash
# Development setup
docker compose up -d

# Django management commands
docker compose run --rm django python manage.py migrate
docker compose run --rm django python manage.py makemigrations
docker compose run --rm django python manage.py createsuperuser

# Testing - Run single test
docker compose run --rm django pytest apps/users/tests/test_models.py::test_user_creation
docker compose run --rm django pytest apps/users/tests/ -k "test_user_creation" -v

# Testing - Run all tests
docker compose run --rm django pytest

# Testing - With coverage
docker compose run --rm django coverage run -m pytest
docker compose run --rm django coverage report

# Type checking
docker compose run --rm django mypy apps

# Linting (ruff handles both linting and formatting)
docker compose run --rm django ruff check backend/ --fix
docker compose run --rm django ruff format backend/

# Create new app (ONLY this runs locally)
python backend/manage.py startapp new_app_name
```

### Frontend (Vue.js)

```bash
# Development
docker compose run --rm frontend npm run dev
# OR locally (your choice)
npm run dev

# Type checking
docker compose run --rm frontend npm run type-check

# Testing - Run single test
docker compose run --rm frontend npm test -- UserAuth.test.ts
docker compose run --rm frontend npm test -- --run UserAuth.test.ts

# Testing - Run all tests
docker compose run --rm frontend npm run test:run

# Testing - With coverage
docker compose run --rm frontend npm run test:run -- --coverage

# Build
docker compose run --rm frontend npm run build

# Generate API client (after backend changes)
docker compose run --rm frontend npm run generate:api
```

### Mobile (Flutter)

```bash
# Testing - Run single test
flutter test test/auth_test.dart

# Testing - Run all tests  
flutter test

# Testing - With coverage
flutter test --coverage

# Type checking/Analysis
flutter analyze

# Code generation (after model changes)
flutter pub run build_runner build

# Linting
flutter lint
```

## Code Style Guidelines

### Python (Backend)

**Import Style:**

- Use ruff with single-line imports: `from foo import bar`
- Group imports: standard library, third-party, local
- NO inline imports

**Type Hints:**

- ALL functions must have explicit return types
- Use `mypy strict mode` - no implicit `Any`
- Prefer `unknown` over `Any` for truly unknown types

**Naming Conventions:**

- Functions: `snake_case` with descriptive names (`get_user_by_email()`)
- Classes: `PascalCase`
- Constants: `UPPER_SNAKE_CASE`
- Variables: `snake_case`

**Error Handling:**

- Use specific exception types
- Include descriptive error messages
- Handle Django's `ATOMIC_REQUESTS` transaction rollbacks properly

**File Organization:**

- Max 500 lines per file
- Domain-driven structure (group by feature, not type)
- Use Django apps as module boundaries

### TypeScript/Vue.js (Frontend)

**Import Style:**

- Use ES6 imports/exports
- All imports at top of file
- Path aliases: `@/components/...`, `@/composables/...`

**Type Safety:**

- **NO `any` types** - ever
- Strict TypeScript mode enabled
- Use `unknown` for truly unknown types
- Runtime validation with Zod schemas (mirror TypeScript types)

**Vue 3 Composition API:**

- Use `<script setup>` syntax
- Prefer composables over mixins
- Use `ref()` for primitives, `reactive()` for objects
- Explicit return types on all functions

**Naming Conventions:**

- Components: `PascalCase` (`UserProfile.vue`)
- Composables: `useCamelCase` (`useUserProfile.ts`)
- Functions: `camelCase` with descriptive names
- Constants: `UPPER_SNAKE_CASE` in dedicated files

**Error Handling:**

- Check SDK errors: `if (response && 'error' in response && response.error)`
- Use try/catch with proper error types
- Axios configured to throw on 4xx/5xx errors

### Flutter (Mobile)

**Import Style:**

- Group imports: Dart core, Flutter, packages, local
- Use relative imports for same-package files

**Type Safety:**

- Enable strict null safety
- Use `final` by default, `const` where possible
- Explicit types when not obvious from context

**Naming Conventions:**

- Classes: `PascalCase`
- Methods/Functions: `camelCase`
- Variables: `camelCase`
- Constants: `UPPER_SNAKE_CASE`
- Files: `snake_case.dart`

**State Management:**

- Use Riverpod providers
- Prefer `StateNotifierProvider` for complex state
- Keep widgets small and focused

## Testing Requirements

### Test-Driven Development (TDD) Workflow

1. **RED**: Write failing test first
2. **GREEN**: Write minimal implementation to pass test
3. **REFACTOR**: Improve code while keeping tests green

### Coverage Requirements

- **Backend**: Minimum 85% coverage (90% for data, 95% for security)
- **Frontend**: Minimum 80% coverage
- **Mobile**: Minimum 80% coverage

### Test Organization

- **Backend**: `tests.py` or `tests/` directory per app
- **Frontend**: Co-locate with components (`Component.test.ts`)
- **Mobile**: `test/` directory at root

## Critical Gotchas

1. **Django ATOMIC_REQUESTS**: When data appears then disappears, check for ValidationError causing transaction rollback. Use `@transaction.non_atomic_requests` decorator when needed.

2. **Generated API Client**: Never manually edit `frontend/src/api/`. Regenerate with `npm run generate:api` after backend changes.

3. **Single Responsibility**: Files approaching 500 lines MUST be split. Components with >3 responsibilities need extraction.

4. **Consistent Docker Usage**: All backend commands run via Docker except `startapp`. Frontend can run locally or in Docker.

## File Organization Rules

- **Max 500 lines per file** - split immediately when approaching limit
- **Domain-driven organization** - group by feature, not by type
- **Descriptive naming** - `getUserByEmail()` not `getUser()`
- **Centralized constants** - use dedicated files for enums/config

## Quality Assurance

Before committing:

1. Run all tests locally
2. Check type safety (`mypy apps`, `npm run type-check`, `flutter analyze`)
3. Run linters (`ruff check`, frontend linting)
4. Verify API client generation if backend changed
5. Check file sizes and organization

CI runs these automatically - treat it as a safety net, not your test runner.
