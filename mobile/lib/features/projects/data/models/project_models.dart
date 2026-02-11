import 'package:freezed_annotation/freezed_annotation.dart';

part 'project_models.freezed.dart';
part 'project_models.g.dart';

// ignore_for_file: invalid_annotation_target

/// Status enum matching Django model
enum ProjectStatus {
  draft,
  active,
  completed,
  archived;

  String get value {
    switch (this) {
      case ProjectStatus.draft:
        return 'draft';
      case ProjectStatus.active:
        return 'active';
      case ProjectStatus.completed:
        return 'completed';
      case ProjectStatus.archived:
        return 'archived';
    }
  }

  String get label {
    switch (this) {
      case ProjectStatus.draft:
        return 'Draft';
      case ProjectStatus.active:
        return 'Active';
      case ProjectStatus.completed:
        return 'Completed';
      case ProjectStatus.archived:
        return 'Archived';
    }
  }

  static ProjectStatus fromString(String value) {
    return ProjectStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => ProjectStatus.draft,
    );
  }
}

/// Priority enum matching Django model
/// 1 = Low, 2 = Medium, 3 = High, 4 = Critical
enum ProjectPriority {
  low(1),
  medium(2),
  high(3),
  critical(4);

  const ProjectPriority(this.value);
  final int value;

  String get label {
    switch (this) {
      case ProjectPriority.low:
        return 'Low';
      case ProjectPriority.medium:
        return 'Medium';
      case ProjectPriority.high:
        return 'High';
      case ProjectPriority.critical:
        return 'Critical';
    }
  }

  static ProjectPriority fromInt(int value) {
    return ProjectPriority.values.firstWhere(
      (priority) => priority.value == value,
      orElse: () => ProjectPriority.low,
    );
  }
}

/// Project model
@freezed
class Project with _$Project {
  const factory Project({
    required String uuid,
    required String name,
    String? description,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @ProjectStatusConverter() required ProjectStatus status,
    @ProjectPriorityConverter() required ProjectPriority priority,
    @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'due_date') DateTime? dueDate,
  }) = _Project;

  factory Project.fromJson(Map<String, dynamic> json) => _$ProjectFromJson(json);
}

/// Project create request
@freezed
class ProjectCreateRequest with _$ProjectCreateRequest {
  const factory ProjectCreateRequest({
    required String name,
    String? description,
    @ProjectStatusConverter() ProjectStatus? status,
    @ProjectPriorityConverter() ProjectPriority? priority,
    @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'due_date') DateTime? dueDate,
  }) = _ProjectCreateRequest;

  factory ProjectCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$ProjectCreateRequestFromJson(json);
}

/// Project update request
@freezed
class ProjectUpdateRequest with _$ProjectUpdateRequest {
  const factory ProjectUpdateRequest({
    required String name,
    String? description,
    @ProjectStatusConverter() ProjectStatus? status,
    @ProjectPriorityConverter() ProjectPriority? priority,
    @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'due_date') DateTime? dueDate,
  }) = _ProjectUpdateRequest;

  factory ProjectUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$ProjectUpdateRequestFromJson(json);
}

/// Project patch request (partial update)
@freezed
class ProjectPatchRequest with _$ProjectPatchRequest {
  const factory ProjectPatchRequest({
    String? name,
    String? description,
    @ProjectStatusConverter() ProjectStatus? status,
    @ProjectPriorityConverter() ProjectPriority? priority,
    @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'due_date') DateTime? dueDate,
  }) = _ProjectPatchRequest;

  factory ProjectPatchRequest.fromJson(Map<String, dynamic> json) =>
      _$ProjectPatchRequestFromJson(json);
}

/// Project filters for list queries
@freezed
class ProjectFilters with _$ProjectFilters {
  const factory ProjectFilters({
    ProjectStatus? status,
    String? search,
    String? ordering,
  }) = _ProjectFilters;

  factory ProjectFilters.fromJson(Map<String, dynamic> json) =>
      _$ProjectFiltersFromJson(json);
}

// Custom JSON converters for enums

class ProjectStatusConverter implements JsonConverter<ProjectStatus, String> {
  const ProjectStatusConverter();

  @override
  ProjectStatus fromJson(String json) => ProjectStatus.fromString(json);

  @override
  String toJson(ProjectStatus object) => object.value;
}

class ProjectPriorityConverter implements JsonConverter<ProjectPriority, int> {
  const ProjectPriorityConverter();

  @override
  ProjectPriority fromJson(int json) => ProjectPriority.fromInt(json);

  @override
  int toJson(ProjectPriority object) => object.value;
}
