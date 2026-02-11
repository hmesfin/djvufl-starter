import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/errors/failures.dart';
import '../models/project_models.dart';
import '../../../../config/api.dart';

/// Projects Service
///
/// Handles all project-related API calls:
/// - List all projects
/// - Get single project
/// - Create project
/// - Update project
/// - Delete project
class ProjectsService {
  ProjectsService(this._client);

  final DioClient _client;

  /// List all projects
  /// Returns Array of projects
  Future<List<Project>> list({ProjectFilters? filters}) async {
    try {
      final response = await _client.dio.get<List<dynamic>>(
        ApiEndpoints.projectsList,
        queryParameters: filters?.toJson(),
      );

      final projects = <Project>[];
      for (final item in response.data!) {
        projects.add(Project.fromJson(item as Map<String, dynamic>));
      }
      return projects;
    } on DioException catch (e) {
      if (e.error is AppException) {
        throw e.error as AppException;
      }
      throw const AppException(AppFailure.unknown(message: 'Failed to fetch projects'));
    }
  }

  /// Get a single project by ID
  /// Returns Project data
  Future<Project> get(String id) async {
    try {
      final response = await _client.dio.get<Map<String, dynamic>>(
        ApiEndpoints.projectDetail(id),
      );
      return Project.fromJson(response.data!);
    } on DioException catch (e) {
      if (e.error is AppException) {
        throw e.error as AppException;
      }
      throw const AppException(AppFailure.unknown(message: 'Failed to fetch project'));
    }
  }

  /// Create a new project
  /// Returns Created project
  Future<Project> create(ProjectCreateRequest data) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        ApiEndpoints.projectCreate,
        data: data.toJson(),
      );
      return Project.fromJson(response.data!);
    } on DioException catch (e) {
      if (e.error is AppException) {
        throw e.error as AppException;
      }
      throw const AppException(AppFailure.unknown(message: 'Failed to create project'));
    }
  }

  /// Update an existing project
  /// Returns Updated project
  Future<Project> update(String id, ProjectUpdateRequest data) async {
    try {
      final response = await _client.dio.put<Map<String, dynamic>>(
        ApiEndpoints.projectUpdate(id),
        data: data.toJson(),
      );
      return Project.fromJson(response.data!);
    } on DioException catch (e) {
      if (e.error is AppException) {
        throw e.error as AppException;
      }
      throw const AppException(AppFailure.unknown(message: 'Failed to update project'));
    }
  }

  /// Partial update of a project
  /// Returns Updated project
  Future<Project> patch(String id, ProjectPatchRequest data) async {
    try {
      final response = await _client.dio.patch<Map<String, dynamic>>(
        ApiEndpoints.projectUpdate(id),
        data: data.toJson(),
      );
      return Project.fromJson(response.data!);
    } on DioException catch (e) {
      if (e.error is AppException) {
        throw e.error as AppException;
      }
      throw const AppException(AppFailure.unknown(message: 'Failed to update project'));
    }
  }

  /// Delete a project
  Future<void> delete(String id) async {
    try {
      await _client.dio.delete<dynamic>(
        ApiEndpoints.projectDelete(id),
      );
    } on DioException catch (e) {
      if (e.error is AppException) {
        throw e.error as AppException;
      }
      throw const AppException(AppFailure.unknown(message: 'Failed to delete project'));
    }
  }
}
