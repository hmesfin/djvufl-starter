// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProjectImpl _$$ProjectImplFromJson(Map<String, dynamic> json) =>
    _$ProjectImpl(
      uuid: json['uuid'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      status: const ProjectStatusConverter().fromJson(json['status'] as String),
      priority: const ProjectPriorityConverter().fromJson(
        (json['priority'] as num).toInt(),
      ),
      startDate: json['start_date'] == null
          ? null
          : DateTime.parse(json['start_date'] as String),
      dueDate: json['due_date'] == null
          ? null
          : DateTime.parse(json['due_date'] as String),
    );

Map<String, dynamic> _$$ProjectImplToJson(_$ProjectImpl instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'name': instance.name,
      'description': instance.description,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'status': const ProjectStatusConverter().toJson(instance.status),
      'priority': const ProjectPriorityConverter().toJson(instance.priority),
      'start_date': instance.startDate?.toIso8601String(),
      'due_date': instance.dueDate?.toIso8601String(),
    };

_$ProjectCreateRequestImpl _$$ProjectCreateRequestImplFromJson(
  Map<String, dynamic> json,
) => _$ProjectCreateRequestImpl(
  name: json['name'] as String,
  description: json['description'] as String?,
  status: _$JsonConverterFromJson<String, ProjectStatus>(
    json['status'],
    const ProjectStatusConverter().fromJson,
  ),
  priority: _$JsonConverterFromJson<int, ProjectPriority>(
    json['priority'],
    const ProjectPriorityConverter().fromJson,
  ),
  startDate: json['start_date'] == null
      ? null
      : DateTime.parse(json['start_date'] as String),
  dueDate: json['due_date'] == null
      ? null
      : DateTime.parse(json['due_date'] as String),
);

Map<String, dynamic> _$$ProjectCreateRequestImplToJson(
  _$ProjectCreateRequestImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'status': _$JsonConverterToJson<String, ProjectStatus>(
    instance.status,
    const ProjectStatusConverter().toJson,
  ),
  'priority': _$JsonConverterToJson<int, ProjectPriority>(
    instance.priority,
    const ProjectPriorityConverter().toJson,
  ),
  'start_date': instance.startDate?.toIso8601String(),
  'due_date': instance.dueDate?.toIso8601String(),
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

_$ProjectUpdateRequestImpl _$$ProjectUpdateRequestImplFromJson(
  Map<String, dynamic> json,
) => _$ProjectUpdateRequestImpl(
  name: json['name'] as String,
  description: json['description'] as String?,
  status: _$JsonConverterFromJson<String, ProjectStatus>(
    json['status'],
    const ProjectStatusConverter().fromJson,
  ),
  priority: _$JsonConverterFromJson<int, ProjectPriority>(
    json['priority'],
    const ProjectPriorityConverter().fromJson,
  ),
  startDate: json['start_date'] == null
      ? null
      : DateTime.parse(json['start_date'] as String),
  dueDate: json['due_date'] == null
      ? null
      : DateTime.parse(json['due_date'] as String),
);

Map<String, dynamic> _$$ProjectUpdateRequestImplToJson(
  _$ProjectUpdateRequestImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'status': _$JsonConverterToJson<String, ProjectStatus>(
    instance.status,
    const ProjectStatusConverter().toJson,
  ),
  'priority': _$JsonConverterToJson<int, ProjectPriority>(
    instance.priority,
    const ProjectPriorityConverter().toJson,
  ),
  'start_date': instance.startDate?.toIso8601String(),
  'due_date': instance.dueDate?.toIso8601String(),
};

_$ProjectPatchRequestImpl _$$ProjectPatchRequestImplFromJson(
  Map<String, dynamic> json,
) => _$ProjectPatchRequestImpl(
  name: json['name'] as String?,
  description: json['description'] as String?,
  status: _$JsonConverterFromJson<String, ProjectStatus>(
    json['status'],
    const ProjectStatusConverter().fromJson,
  ),
  priority: _$JsonConverterFromJson<int, ProjectPriority>(
    json['priority'],
    const ProjectPriorityConverter().fromJson,
  ),
  startDate: json['start_date'] == null
      ? null
      : DateTime.parse(json['start_date'] as String),
  dueDate: json['due_date'] == null
      ? null
      : DateTime.parse(json['due_date'] as String),
);

Map<String, dynamic> _$$ProjectPatchRequestImplToJson(
  _$ProjectPatchRequestImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'status': _$JsonConverterToJson<String, ProjectStatus>(
    instance.status,
    const ProjectStatusConverter().toJson,
  ),
  'priority': _$JsonConverterToJson<int, ProjectPriority>(
    instance.priority,
    const ProjectPriorityConverter().toJson,
  ),
  'start_date': instance.startDate?.toIso8601String(),
  'due_date': instance.dueDate?.toIso8601String(),
};

_$ProjectFiltersImpl _$$ProjectFiltersImplFromJson(Map<String, dynamic> json) =>
    _$ProjectFiltersImpl(
      status: $enumDecodeNullable(_$ProjectStatusEnumMap, json['status']),
      search: json['search'] as String?,
      ordering: json['ordering'] as String?,
    );

Map<String, dynamic> _$$ProjectFiltersImplToJson(
  _$ProjectFiltersImpl instance,
) => <String, dynamic>{
  'status': _$ProjectStatusEnumMap[instance.status],
  'search': instance.search,
  'ordering': instance.ordering,
};

const _$ProjectStatusEnumMap = {
  ProjectStatus.draft: 'draft',
  ProjectStatus.active: 'active',
  ProjectStatus.completed: 'completed',
  ProjectStatus.archived: 'archived',
};
