import '../../../../core/errors/failures.dart';
import '../models/project_models.dart';
import '../services/projects_service.dart';

/// Projects Repository
///
/// Manages projects data and coordinates between the service and UI.
class ProjectsRepository {
  ProjectsRepository({
    required ProjectsService service,
  }) : _service = service;

  final ProjectsService _service;

  List<Project>? _cachedProjects;

  /// Get cached projects list
  List<Project>? get cachedProjects => _cachedProjects;

  /// List all projects
  Future<List<Project>> list({ProjectFilters? filters}) async {
    try {
      final projects = await _service.list(filters: filters);
      _cachedProjects = projects;
      return projects;
    } on AppException {
      rethrow;
    }
  }

  /// Get a single project by ID
  Future<Project> get(String id) async {
    try {
      return await _service.get(id);
    } on AppException {
      rethrow;
    }
  }

  /// Create a new project
  Future<Project> create(ProjectCreateRequest data) async {
    try {
      final project = await _service.create(data);
      // Add to cache
      _cachedProjects = [...?_cachedProjects, project];
      return project;
    } on AppException {
      rethrow;
    }
  }

  /// Update an existing project
  Future<Project> update(String id, ProjectUpdateRequest data) async {
    try {
      final project = await _service.update(id, data);
      // Update cache
      _cachedProjects = _cachedProjects?.map((p) => p.uuid == id ? project : p).toList();
      return project;
    } on AppException {
      rethrow;
    }
  }

  /// Partial update of a project
  Future<Project> patch(String id, ProjectPatchRequest data) async {
    try {
      final project = await _service.patch(id, data);
      // Update cache
      _cachedProjects = _cachedProjects?.map((p) => p.uuid == id ? project : p).toList();
      return project;
    } on AppException {
      rethrow;
    }
  }

  /// Delete a project
  Future<void> delete(String id) async {
    try {
      await _service.delete(id);
      // Remove from cache
      _cachedProjects = _cachedProjects?.where((p) => p.uuid != id).toList();
    } on AppException {
      rethrow;
    }
  }

  /// Clear cache
  void clearCache() {
    _cachedProjects = null;
  }

  /// Refresh projects from server
  Future<List<Project>> refresh({ProjectFilters? filters}) async {
    clearCache();
    return list(filters: filters);
  }
}
