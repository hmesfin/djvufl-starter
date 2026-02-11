# DjVuFL Mobile - Flutter App

Flutter mobile application for the DjVuFL full-stack starter.

## Tech Stack

- **Framework**: Flutter 3.24+ (Dart 3.10+)
- **State Management**: flutter_riverpod
- **Navigation**: go_router
- **HTTP Client**: dio
- **Storage**: shared_preferences, flutter_secure_storage
- **UI Components**: Material 3 (built-in), table_calendar
- **Code Generation**: freezed, json_serializable, build_runner
- **Testing**: flutter_test

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── app.dart                  # Root app widget
├── config/                   # Configuration
│   ├── api.dart             # API endpoints and config
│   └── routes.dart          # go_router configuration
├── core/                     # Core infrastructure
│   ├── errors/              # Error types (failures)
│   ├── network/             # HTTP client (dio wrapper)
│   ├── storage/             # Storage service
│   └── theme/               # App theming
├── features/                 # Feature modules
│   ├── auth/                # Authentication feature
│   │   ├── data/            # Data layer
│   │   │   ├── models/      # Freezed models
│   │   │   ├── repositories/# Data repositories
│   │   │   └── services/    # API services
│   │   └── presentation/   # UI layer
│   │       ├── providers/   # Riverpod providers
│   │       ├── screens/     # Screens
│   │       └── widgets/     # Feature widgets
│   └── projects/           # Projects feature
│       └── (same structure)
└── shared/                   # Shared code
    ├── utils/               # Utility functions
    └── widgets/             # Reusable widgets
```

## Quick Start

### Prerequisites

- Flutter SDK 3.24+
- Dart 3.10+
- Android Studio / Xcode (for mobile development)
- For physical devices: Enable USB debugging

### Installation

```bash
cd mobile
flutter pub get
```

### Run the App

```bash
# Debug mode
flutter run

# Specific device
flutter devices
flutter run -d <device-id>

# Release mode
flutter run --release
```

### Build

```bash
# Android APK
flutter build apk --release

# Android App Bundle (Play Store)
flutter build appbundle --release

# iOS (requires macOS + Xcode)
flutter build ios --release
```

## Development Workflow

### Code Generation

This project uses code generation for:
- Freezed models (immutable data classes)
- JSON serialization
- Riverpod providers

After modifying models with `@freezed` or `@JsonSerializable`, run:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Watch mode (requires flutter_test 3.7+)
flutter test --watch

# Specific test file
flutter test test/widget_test.dart

# Run integration tests
flutter test integration_test/
```

### Static Analysis

```bash
# Analyze code
flutter analyze

# Fix issues automatically
dart fix --apply
```

## Key Patterns

### State Management (Riverpod)

```dart
// Provider (read-only)
final projectsProvider = Provider<ProjectsService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ProjectsService(dioClient);
});

// StateNotifier (mutable state)
class ProjectsNotifier extends StateNotifier<ProjectsState> {
  ProjectsNotifier(this._repository) : super(const ProjectsState());

  Future<void> loadProjects() async {
    state = state.copyWith(isLoading: true);
    // ... load data ...
    state = state.copyWith(projects: projects, isLoading: false);
  }
}

// Watch in widget
final projectsState = ref.watch(projectsProvider);
```

### Navigation (go_router)

```dart
// Navigate
context.go('/projects');
context.push('/projects/new');

// With parameters
context.push('/projects/$uuid');

// Named routes
GoRoute(
  path: '/projects/:uuid',
  pageBuilder: (context, state) {
    final uuid = state.pathParameters['uuid']!;
    return MaterialPage(child: ProjectDetailScreen(uuid: uuid));
  },
);
```

### API Client (Dio)

```dart
// The DioClient automatically adds JWT tokens
final response = await dioClient.dio.get('/api/projects/');

// Handle errors
try {
  final project = await projectsService.get(id);
} on AppException catch (e) {
  // e.failure contains the error details
}
```

### Freezed Models

```dart
@freezed
class Project with _$Project {
  const factory Project({
    required String uuid,
    required String name,
    @ProjectStatusConverter() required ProjectStatus status,
  }) = _Project;

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);
}
```

## Environment Configuration

### Development API URL

For local development, the app uses ngrok to connect to your local backend:

```dart
// lib/config/api.dart
static String getApiBaseUrl() {
  if (kDebugMode) {
    return 'https://your-ngrok-url.ngrok-free.dev';
  }
  return 'https://api.yourdomain.com'; // Production
}
```

Update the ngrok URL in `lib/config/api.dart` when starting development.

### Alternative: Android Emulator

If not using ngrok, Android emulators can use special host addresses:

```dart
// For Android emulator
return 'http://10.0.2.2:8000';

// For iOS simulator
return 'http://localhost:8000';
```

## Troubleshooting

### Build Issues

```bash
# Clean build
flutter clean
flutter pub get
flutter build apk --debug
```

### Code Generation Errors

```bash
# Clean and regenerate
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### iOS Build Issues

```bash
# Clean iOS pods (if using CocoaPods)
cd ios
pod install
cd ..
flutter clean
flutter pub get
```

### Inotify Watcher Limit (Linux)

```bash
# Increase file watcher limit
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

## Testing Commands

```bash
# Widget tests
flutter test test/widget_test.dart

# Unit tests
flutter test test/unit/

# Integration tests
flutter test integration_test/

# With coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## CI/CD

The app uses GitHub Actions for CI:

- **mobile-analyze**: Static analysis with `flutter analyze`
- **mobile-tests**: Unit and widget tests with coverage

See `.github/workflows/ci.yml` for details.

## Migration Notes

This Flutter app was migrated from the React Native version in `mobile_react_native/`.
The React Native code is kept for reference during the migration.

Key differences:
- **State Management**: Zustand → Riverpod
- **Navigation**: React Navigation → go_router
- **Validation**: Zod → Freezed + custom validators
- **Styling**: React Native Paper → Material 3
- **HTTP**: Axios → Dio
