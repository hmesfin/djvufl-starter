# Project Structure Reference

## Root Level Structure

```
project-root/
├── backend/              # Django backend
├── frontend/             # Vue.js frontend
├── mobile/              # Flutter mobile app
├── mobile_react_native/ # React Native reference (deprecated)
├── compose/             # Docker service configurations
├── .envs/               # Environment variables
├── docs/                # Sphinx documentation
├── project-docs/        # Project-specific documentation
├── docker-compose.yml   # Local development compose file
├── docker-compose.production.yml
├── docker-compose.staging.yml
└── README.md
```

## Backend Structure (`backend/`)

```
backend/
├── apps/
│   ├── users/           # Custom User model (email-based)
│   ├── shared/          # Shared utilities, base classes
│   ├── <app_name>/      # Your Django apps go here
│   │   ├── __init__.py
│   │   ├── models.py    # Model definitions with type hints
│   │   ├── api/
│   │   │   ├── serializers.py
│   │   │   └── views.py # DRF ViewSets
│   │   ├── migrations/
│   │   ├── tests.py     # pytest tests
│   │   └── admin.py     # Django admin config
│   ├── templates/       # Email templates only
│   └── conftest.py      # pytest fixtures
├── config/
│   ├── settings/
│   │   ├── base.py      # Base settings
│   │   ├── local.py     # Development
│   │   ├── test.py      # Testing
│   │   └── production.py
│   ├── api_router.py    # DRF router (register ViewSets here)
│   ├── urls.py          # Root URL configuration
│   ├── asgi.py
│   ├── wsgi.py
│   └── celery_app.py
├── locale/              # i18n translations
├── manage.py
├── pyproject.toml       # Python dependencies (uv)
├── uv.lock
├── pytest.ini
└── .python-version
```

### Backend File Organization Principles

1. **Apps in `backend/apps/`**: All Django apps live here
2. **API endpoints in `api/` subdirectory**: Keeps API code separate
3. **No template views**: Django only serves API and admin
4. **Tests co-located**: `tests.py` or `tests/` directory per app
5. **Type hints everywhere**: All functions/methods typed

## Frontend Structure (`frontend/`)

```
frontend/
├── src/
│   ├── api/              # AUTO-GENERATED - DO NOT EDIT
│   │   ├── sdk.gen.ts    # Generated API functions
│   │   └── types.gen.ts  # Generated TypeScript types
│   ├── components/
│   │   ├── ui/           # Shadcn-vue components
│   │   └── <feature>/    # Domain components
│   │       ├── ComponentName.vue
│   │       └── __tests__/
│   │           └── ComponentName.test.ts
│   ├── composables/      # Vue composables
│   │   └── use<Feature>.ts
│   ├── stores/           # Pinia stores
│   ├── views/            # Route views
│   ├── router/           # Vue Router config
│   ├── layouts/          # Layout components
│   ├── lib/
│   │   ├── api-client.ts # Axios client with auth
│   │   └── utils.ts      # Utility functions
│   ├── schemas/          # Zod validation schemas
│   ├── constants/        # App constants
│   ├── types/            # Manual TypeScript types
│   ├── assets/           # Static assets
│   ├── App.vue
│   └── main.ts
├── public/               # Public static files
├── components.json       # Shadcn-vue config
├── package.json
├── tsconfig.json         # TypeScript config (strict mode)
├── vite.config.ts
├── tailwind.config.js
├── vitest.config.ts      # Test configuration
└── playwright.config.ts  # E2E test config
```

### Frontend File Organization Principles

1. **Never edit `src/api/`**: Auto-generated from backend OpenAPI schema
2. **Components by domain**: `components/<feature>/ComponentName.vue`
3. **Tests co-located**: `__tests__/` directories next to components
4. **Logic in composables**: Extract reusable logic to `composables/`
5. **Type everything**: No `any` types, strict TypeScript mode
6. **Max 500 lines**: Split large components into smaller ones

## Mobile Structure (`mobile/` - Flutter)

```
mobile/
├── lib/
│   ├── main.dart              # App entry point
│   ├── app.dart               # Root app widget with providers
│   ├── config/
│   │   ├── api.dart           # API configuration (base URL, etc.)
│   │   └── routes.dart        # go_router configuration
│   ├── core/
│   │   ├── errors/
│   │   │   ├── exceptions.dart   # Custom exception classes
│   │   │   └── failures.dart      # Failure types for error handling
│   │   ├── network/
│   │   │   ├── dio_client.dart    # Dio HTTP client
│   │   │   └── network_notifier.dart  # Connectivity monitoring
│   │   ├── storage/
│   │   │   ├── secure_storage.dart   # flutter_secure_storage wrapper
│   │   │   └── preferences_storage.dart # shared_preferences wrapper
│   │   └── theme/
│   │       ├── app_theme.dart        # Material 3 themes
│   │       └── theme_notifier.dart   # Theme state management
│   ├── features/
│   │   ├── auth/                  # Authentication feature
│   │   │   ├── data/
│   │   │   │   ├── models/        # Freezed models (User, LoginRequest, etc.)
│   │   │   │   ├── repositories/   # Data repositories
│   │   │   │   └── services/       # API services
│   │   │   └── presentation/
│   │   │       ├── providers/      # Riverpod providers
│   │   │       ├── screens/        # Auth screens (Login, Register, OTP)
│   │   │       └── widgets/        # Auth-specific widgets
│   │   ├── projects/              # Projects feature
│   │   │   ├── data/
│   │   │   │   ├── models/        # Project models (Freezed)
│   │   │   │   ├── repositories/   # Projects repository
│   │   │   │   └── services/       # Projects API service
│   │   │   └── presentation/
│   │   │       ├── providers/      # Projects state provider
│   │   │       ├── screens/        # List, Detail, Form screens
│   │   │       └── widgets/        # Project cards, badges
│   │   └── <feature>/             # Other features follow same pattern
│   ├── shared/
│   │   ├── utils/
│   │   │   └── validators.dart    # Form validation functions
│   │   └── widgets/
│   │       ├── offline_banner.dart # Network status banner
│   │       └── <common_widgets>/   # Shared UI components
│   └── generated/                 # Auto-generated (freezed, riverpod)
├── integration_test/              # Integration tests (requires device)
│   ├── app_test.dart
│   ├── auth_flow_test.dart
│   ├── projects_crud_test.dart
│   └── theme_test.dart
├── test/                         # Unit and widget tests
│   └── (mirrors lib/ structure)
├── pubspec.yaml                  # Dependencies and project config
├── analysis_options.yaml         # Dart analyzer settings
└── openapi-generator.yaml        # OpenAPI code generation config
```

### Mobile File Organization Principles

1. **Feature-first structure**: Group by domain feature (auth, projects, etc.)
2. **Clean Architecture layers**: data (models, repos, services) → presentation (providers, screens, widgets)
3. **Code generation**: Use `freezed` for models, `riverpod_generator` for providers
4. **Never edit `generated/`**: Auto-generated from annotations
5. **Tests co-located**: Keep tests near implementation or in mirrored test/ directory
6. **Shared utilities**: Common code in `shared/` (validators, widgets, utils)
7. **Max 500 lines**: Split large widgets/files into smaller components

### Key Patterns

**Data Models (Freezed)**:
```dart
@freezed
class Project with _$Project {
  const factory Project({
    required String uuid,
    required String name,
    String? description,
    required ProjectStatus status,
  }) = _Project;

  factory Project.fromJson(Map<String, dynamic> json) => _$ProjectFromJson(json);
}
```

**State Management (Riverpod)**:
```dart
@riverpod
class Projects extends _$Projects {
  @override
  Future<List<Project>> build() async {
    return ref.read(projectsRepository).fetchProjects();
  }

  Future<void> create(CreateProjectRequest request) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(projectsRepository).create(request);
      return ref.read(projectsRepository).fetchProjects();
    });
  }
}
```

**Navigation (go_router)**:
```dart
GoRoute(
  path: '/projects/:uuid',
  builder: (context, state) {
    final uuid = state.pathParameters['uuid']!;
    return ProjectDetailScreen(projectUuid: uuid);
  },
)
```
