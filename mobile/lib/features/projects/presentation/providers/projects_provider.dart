import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/presentation/providers/auth_provider.dart' show dioClientProvider;
import '../../data/models/project_models.dart';
import '../../data/repositories/projects_repository.dart';
import '../../data/services/projects_service.dart';

/// Projects service provider
final projectsServiceProvider = Provider<ProjectsService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ProjectsService(dioClient);
});

/// Projects repository provider
final projectsRepositoryProvider = Provider<ProjectsRepository>((ref) {
  final service = ref.watch(projectsServiceProvider);
  return ProjectsRepository(service: service);
});

/// Projects state
class ProjectsState {
  const ProjectsState({
    this.projects = const [],
    this.isLoading = false,
    this.error,
    this.filters,
  });

  final List<Project> projects;
  final bool isLoading;
  final String? error;
  final ProjectFilters? filters;

  ProjectsState copyWith({
    List<Project>? projects,
    bool? isLoading,
    String? error,
    ProjectFilters? filters,
  }) {
    return ProjectsState(
      projects: projects ?? this.projects,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      filters: filters ?? this.filters,
    );
  }
}

/// Projects state notifier
class ProjectsNotifier extends StateNotifier<ProjectsState> {
  ProjectsNotifier(this._repository) : super(const ProjectsState());

  final ProjectsRepository _repository;

  /// Load projects
  Future<void> loadProjects({ProjectFilters? filters}) async {
    state = state.copyWith(isLoading: true, error: null, filters: filters);

    try {
      final projects = await _repository.list(filters: filters);
      state = state.copyWith(projects: projects, isLoading: false);
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.failure.when(
          network: (message, _) => message,
          auth: (message) => message,
          validation: (message, _) => message,
          notFound: (message) => message,
          server: (message, _) => message,
          unknown: (message, _) => message,
        ),
      );
    }
  }

  /// Refresh projects
  Future<void> refresh({ProjectFilters? filters}) async {
    await _repository.refresh(filters: filters);
    await loadProjects(filters: filters);
  }

  /// Create a new project
  Future<void> createProject(ProjectCreateRequest data) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final project = await _repository.create(data);
      state = state.copyWith(
        projects: [...state.projects, project],
        isLoading: false,
      );
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.failure.when(
          network: (message, _) => message,
          auth: (message) => message,
          validation: (message, _) => message,
          notFound: (message) => message,
          server: (message, _) => message,
          unknown: (message, _) => message,
        ),
      );
      rethrow;
    }
  }

  /// Update a project
  Future<void> updateProject(String id, ProjectUpdateRequest data) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final project = await _repository.update(id, data);
      state = state.copyWith(
        projects: state.projects.map((p) => p.uuid == id ? project : p).toList(),
        isLoading: false,
      );
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.failure.when(
          network: (message, _) => message,
          auth: (message) => message,
          validation: (message, _) => message,
          notFound: (message) => message,
          server: (message, _) => message,
          unknown: (message, _) => message,
        ),
      );
      rethrow;
    }
  }

  /// Delete a project
  Future<void> deleteProject(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.delete(id);
      state = state.copyWith(
        projects: state.projects.where((p) => p.uuid != id).toList(),
        isLoading: false,
      );
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.failure.when(
          network: (message, _) => message,
          auth: (message) => message,
          validation: (message, _) => message,
          notFound: (message) => message,
          server: (message, _) => message,
          unknown: (message, _) => message,
        ),
      );
      rethrow;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Update filters
  void updateFilters(ProjectFilters filters) {
    state = state.copyWith(filters: filters);
    loadProjects(filters: filters);
  }

  /// Clear filters
  void clearFilters() {
    state = state.copyWith(filters: null);
    loadProjects();
  }
}

/// Projects state provider
final projectsProvider =
    StateNotifierProvider<ProjectsNotifier, ProjectsState>((ref) {
  final repository = ref.watch(projectsRepositoryProvider);
  return ProjectsNotifier(repository);
});

/// Individual project provider
final projectProvider = FutureProvider.family<Project, String>((ref, id) async {
  final repository = ref.watch(projectsRepositoryProvider);
  return repository.get(id);
});
