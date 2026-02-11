// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'project_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Project _$ProjectFromJson(Map<String, dynamic> json) {
  return _Project.fromJson(json);
}

/// @nodoc
mixin _$Project {
  String get uuid => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;
  @ProjectStatusConverter()
  ProjectStatus get status => throw _privateConstructorUsedError;
  @ProjectPriorityConverter()
  ProjectPriority get priority => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_date')
  DateTime? get startDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'due_date')
  DateTime? get dueDate => throw _privateConstructorUsedError;

  /// Serializes this Project to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Project
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProjectCopyWith<Project> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProjectCopyWith<$Res> {
  factory $ProjectCopyWith(Project value, $Res Function(Project) then) =
      _$ProjectCopyWithImpl<$Res, Project>;
  @useResult
  $Res call({
    String uuid,
    String name,
    String? description,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
    @ProjectStatusConverter() ProjectStatus status,
    @ProjectPriorityConverter() ProjectPriority priority,
    @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'due_date') DateTime? dueDate,
  });
}

/// @nodoc
class _$ProjectCopyWithImpl<$Res, $Val extends Project>
    implements $ProjectCopyWith<$Res> {
  _$ProjectCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Project
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uuid = null,
    Object? name = null,
    Object? description = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? status = null,
    Object? priority = null,
    Object? startDate = freezed,
    Object? dueDate = freezed,
  }) {
    return _then(
      _value.copyWith(
            uuid: null == uuid
                ? _value.uuid
                : uuid // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as ProjectStatus,
            priority: null == priority
                ? _value.priority
                : priority // ignore: cast_nullable_to_non_nullable
                      as ProjectPriority,
            startDate: freezed == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            dueDate: freezed == dueDate
                ? _value.dueDate
                : dueDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProjectImplCopyWith<$Res> implements $ProjectCopyWith<$Res> {
  factory _$$ProjectImplCopyWith(
    _$ProjectImpl value,
    $Res Function(_$ProjectImpl) then,
  ) = __$$ProjectImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String uuid,
    String name,
    String? description,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
    @ProjectStatusConverter() ProjectStatus status,
    @ProjectPriorityConverter() ProjectPriority priority,
    @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'due_date') DateTime? dueDate,
  });
}

/// @nodoc
class __$$ProjectImplCopyWithImpl<$Res>
    extends _$ProjectCopyWithImpl<$Res, _$ProjectImpl>
    implements _$$ProjectImplCopyWith<$Res> {
  __$$ProjectImplCopyWithImpl(
    _$ProjectImpl _value,
    $Res Function(_$ProjectImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Project
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uuid = null,
    Object? name = null,
    Object? description = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? status = null,
    Object? priority = null,
    Object? startDate = freezed,
    Object? dueDate = freezed,
  }) {
    return _then(
      _$ProjectImpl(
        uuid: null == uuid
            ? _value.uuid
            : uuid // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as ProjectStatus,
        priority: null == priority
            ? _value.priority
            : priority // ignore: cast_nullable_to_non_nullable
                  as ProjectPriority,
        startDate: freezed == startDate
            ? _value.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        dueDate: freezed == dueDate
            ? _value.dueDate
            : dueDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProjectImpl implements _Project {
  const _$ProjectImpl({
    required this.uuid,
    required this.name,
    this.description,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'updated_at') required this.updatedAt,
    @ProjectStatusConverter() required this.status,
    @ProjectPriorityConverter() required this.priority,
    @JsonKey(name: 'start_date') this.startDate,
    @JsonKey(name: 'due_date') this.dueDate,
  });

  factory _$ProjectImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProjectImplFromJson(json);

  @override
  final String uuid;
  @override
  final String name;
  @override
  final String? description;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @override
  @ProjectStatusConverter()
  final ProjectStatus status;
  @override
  @ProjectPriorityConverter()
  final ProjectPriority priority;
  @override
  @JsonKey(name: 'start_date')
  final DateTime? startDate;
  @override
  @JsonKey(name: 'due_date')
  final DateTime? dueDate;

  @override
  String toString() {
    return 'Project(uuid: $uuid, name: $name, description: $description, createdAt: $createdAt, updatedAt: $updatedAt, status: $status, priority: $priority, startDate: $startDate, dueDate: $dueDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProjectImpl &&
            (identical(other.uuid, uuid) || other.uuid == uuid) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    uuid,
    name,
    description,
    createdAt,
    updatedAt,
    status,
    priority,
    startDate,
    dueDate,
  );

  /// Create a copy of Project
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProjectImplCopyWith<_$ProjectImpl> get copyWith =>
      __$$ProjectImplCopyWithImpl<_$ProjectImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProjectImplToJson(this);
  }
}

abstract class _Project implements Project {
  const factory _Project({
    required final String uuid,
    required final String name,
    final String? description,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    @JsonKey(name: 'updated_at') required final DateTime updatedAt,
    @ProjectStatusConverter() required final ProjectStatus status,
    @ProjectPriorityConverter() required final ProjectPriority priority,
    @JsonKey(name: 'start_date') final DateTime? startDate,
    @JsonKey(name: 'due_date') final DateTime? dueDate,
  }) = _$ProjectImpl;

  factory _Project.fromJson(Map<String, dynamic> json) = _$ProjectImpl.fromJson;

  @override
  String get uuid;
  @override
  String get name;
  @override
  String? get description;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;
  @override
  @ProjectStatusConverter()
  ProjectStatus get status;
  @override
  @ProjectPriorityConverter()
  ProjectPriority get priority;
  @override
  @JsonKey(name: 'start_date')
  DateTime? get startDate;
  @override
  @JsonKey(name: 'due_date')
  DateTime? get dueDate;

  /// Create a copy of Project
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProjectImplCopyWith<_$ProjectImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProjectCreateRequest _$ProjectCreateRequestFromJson(Map<String, dynamic> json) {
  return _ProjectCreateRequest.fromJson(json);
}

/// @nodoc
mixin _$ProjectCreateRequest {
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @ProjectStatusConverter()
  ProjectStatus? get status => throw _privateConstructorUsedError;
  @ProjectPriorityConverter()
  ProjectPriority? get priority => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_date')
  DateTime? get startDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'due_date')
  DateTime? get dueDate => throw _privateConstructorUsedError;

  /// Serializes this ProjectCreateRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProjectCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProjectCreateRequestCopyWith<ProjectCreateRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProjectCreateRequestCopyWith<$Res> {
  factory $ProjectCreateRequestCopyWith(
    ProjectCreateRequest value,
    $Res Function(ProjectCreateRequest) then,
  ) = _$ProjectCreateRequestCopyWithImpl<$Res, ProjectCreateRequest>;
  @useResult
  $Res call({
    String name,
    String? description,
    @ProjectStatusConverter() ProjectStatus? status,
    @ProjectPriorityConverter() ProjectPriority? priority,
    @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'due_date') DateTime? dueDate,
  });
}

/// @nodoc
class _$ProjectCreateRequestCopyWithImpl<
  $Res,
  $Val extends ProjectCreateRequest
>
    implements $ProjectCreateRequestCopyWith<$Res> {
  _$ProjectCreateRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProjectCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = freezed,
    Object? status = freezed,
    Object? priority = freezed,
    Object? startDate = freezed,
    Object? dueDate = freezed,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as ProjectStatus?,
            priority: freezed == priority
                ? _value.priority
                : priority // ignore: cast_nullable_to_non_nullable
                      as ProjectPriority?,
            startDate: freezed == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            dueDate: freezed == dueDate
                ? _value.dueDate
                : dueDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProjectCreateRequestImplCopyWith<$Res>
    implements $ProjectCreateRequestCopyWith<$Res> {
  factory _$$ProjectCreateRequestImplCopyWith(
    _$ProjectCreateRequestImpl value,
    $Res Function(_$ProjectCreateRequestImpl) then,
  ) = __$$ProjectCreateRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    String? description,
    @ProjectStatusConverter() ProjectStatus? status,
    @ProjectPriorityConverter() ProjectPriority? priority,
    @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'due_date') DateTime? dueDate,
  });
}

/// @nodoc
class __$$ProjectCreateRequestImplCopyWithImpl<$Res>
    extends _$ProjectCreateRequestCopyWithImpl<$Res, _$ProjectCreateRequestImpl>
    implements _$$ProjectCreateRequestImplCopyWith<$Res> {
  __$$ProjectCreateRequestImplCopyWithImpl(
    _$ProjectCreateRequestImpl _value,
    $Res Function(_$ProjectCreateRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProjectCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = freezed,
    Object? status = freezed,
    Object? priority = freezed,
    Object? startDate = freezed,
    Object? dueDate = freezed,
  }) {
    return _then(
      _$ProjectCreateRequestImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: freezed == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as ProjectStatus?,
        priority: freezed == priority
            ? _value.priority
            : priority // ignore: cast_nullable_to_non_nullable
                  as ProjectPriority?,
        startDate: freezed == startDate
            ? _value.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        dueDate: freezed == dueDate
            ? _value.dueDate
            : dueDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProjectCreateRequestImpl implements _ProjectCreateRequest {
  const _$ProjectCreateRequestImpl({
    required this.name,
    this.description,
    @ProjectStatusConverter() this.status,
    @ProjectPriorityConverter() this.priority,
    @JsonKey(name: 'start_date') this.startDate,
    @JsonKey(name: 'due_date') this.dueDate,
  });

  factory _$ProjectCreateRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProjectCreateRequestImplFromJson(json);

  @override
  final String name;
  @override
  final String? description;
  @override
  @ProjectStatusConverter()
  final ProjectStatus? status;
  @override
  @ProjectPriorityConverter()
  final ProjectPriority? priority;
  @override
  @JsonKey(name: 'start_date')
  final DateTime? startDate;
  @override
  @JsonKey(name: 'due_date')
  final DateTime? dueDate;

  @override
  String toString() {
    return 'ProjectCreateRequest(name: $name, description: $description, status: $status, priority: $priority, startDate: $startDate, dueDate: $dueDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProjectCreateRequestImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    description,
    status,
    priority,
    startDate,
    dueDate,
  );

  /// Create a copy of ProjectCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProjectCreateRequestImplCopyWith<_$ProjectCreateRequestImpl>
  get copyWith =>
      __$$ProjectCreateRequestImplCopyWithImpl<_$ProjectCreateRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ProjectCreateRequestImplToJson(this);
  }
}

abstract class _ProjectCreateRequest implements ProjectCreateRequest {
  const factory _ProjectCreateRequest({
    required final String name,
    final String? description,
    @ProjectStatusConverter() final ProjectStatus? status,
    @ProjectPriorityConverter() final ProjectPriority? priority,
    @JsonKey(name: 'start_date') final DateTime? startDate,
    @JsonKey(name: 'due_date') final DateTime? dueDate,
  }) = _$ProjectCreateRequestImpl;

  factory _ProjectCreateRequest.fromJson(Map<String, dynamic> json) =
      _$ProjectCreateRequestImpl.fromJson;

  @override
  String get name;
  @override
  String? get description;
  @override
  @ProjectStatusConverter()
  ProjectStatus? get status;
  @override
  @ProjectPriorityConverter()
  ProjectPriority? get priority;
  @override
  @JsonKey(name: 'start_date')
  DateTime? get startDate;
  @override
  @JsonKey(name: 'due_date')
  DateTime? get dueDate;

  /// Create a copy of ProjectCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProjectCreateRequestImplCopyWith<_$ProjectCreateRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ProjectUpdateRequest _$ProjectUpdateRequestFromJson(Map<String, dynamic> json) {
  return _ProjectUpdateRequest.fromJson(json);
}

/// @nodoc
mixin _$ProjectUpdateRequest {
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @ProjectStatusConverter()
  ProjectStatus? get status => throw _privateConstructorUsedError;
  @ProjectPriorityConverter()
  ProjectPriority? get priority => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_date')
  DateTime? get startDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'due_date')
  DateTime? get dueDate => throw _privateConstructorUsedError;

  /// Serializes this ProjectUpdateRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProjectUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProjectUpdateRequestCopyWith<ProjectUpdateRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProjectUpdateRequestCopyWith<$Res> {
  factory $ProjectUpdateRequestCopyWith(
    ProjectUpdateRequest value,
    $Res Function(ProjectUpdateRequest) then,
  ) = _$ProjectUpdateRequestCopyWithImpl<$Res, ProjectUpdateRequest>;
  @useResult
  $Res call({
    String name,
    String? description,
    @ProjectStatusConverter() ProjectStatus? status,
    @ProjectPriorityConverter() ProjectPriority? priority,
    @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'due_date') DateTime? dueDate,
  });
}

/// @nodoc
class _$ProjectUpdateRequestCopyWithImpl<
  $Res,
  $Val extends ProjectUpdateRequest
>
    implements $ProjectUpdateRequestCopyWith<$Res> {
  _$ProjectUpdateRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProjectUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = freezed,
    Object? status = freezed,
    Object? priority = freezed,
    Object? startDate = freezed,
    Object? dueDate = freezed,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as ProjectStatus?,
            priority: freezed == priority
                ? _value.priority
                : priority // ignore: cast_nullable_to_non_nullable
                      as ProjectPriority?,
            startDate: freezed == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            dueDate: freezed == dueDate
                ? _value.dueDate
                : dueDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProjectUpdateRequestImplCopyWith<$Res>
    implements $ProjectUpdateRequestCopyWith<$Res> {
  factory _$$ProjectUpdateRequestImplCopyWith(
    _$ProjectUpdateRequestImpl value,
    $Res Function(_$ProjectUpdateRequestImpl) then,
  ) = __$$ProjectUpdateRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    String? description,
    @ProjectStatusConverter() ProjectStatus? status,
    @ProjectPriorityConverter() ProjectPriority? priority,
    @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'due_date') DateTime? dueDate,
  });
}

/// @nodoc
class __$$ProjectUpdateRequestImplCopyWithImpl<$Res>
    extends _$ProjectUpdateRequestCopyWithImpl<$Res, _$ProjectUpdateRequestImpl>
    implements _$$ProjectUpdateRequestImplCopyWith<$Res> {
  __$$ProjectUpdateRequestImplCopyWithImpl(
    _$ProjectUpdateRequestImpl _value,
    $Res Function(_$ProjectUpdateRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProjectUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = freezed,
    Object? status = freezed,
    Object? priority = freezed,
    Object? startDate = freezed,
    Object? dueDate = freezed,
  }) {
    return _then(
      _$ProjectUpdateRequestImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: freezed == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as ProjectStatus?,
        priority: freezed == priority
            ? _value.priority
            : priority // ignore: cast_nullable_to_non_nullable
                  as ProjectPriority?,
        startDate: freezed == startDate
            ? _value.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        dueDate: freezed == dueDate
            ? _value.dueDate
            : dueDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProjectUpdateRequestImpl implements _ProjectUpdateRequest {
  const _$ProjectUpdateRequestImpl({
    required this.name,
    this.description,
    @ProjectStatusConverter() this.status,
    @ProjectPriorityConverter() this.priority,
    @JsonKey(name: 'start_date') this.startDate,
    @JsonKey(name: 'due_date') this.dueDate,
  });

  factory _$ProjectUpdateRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProjectUpdateRequestImplFromJson(json);

  @override
  final String name;
  @override
  final String? description;
  @override
  @ProjectStatusConverter()
  final ProjectStatus? status;
  @override
  @ProjectPriorityConverter()
  final ProjectPriority? priority;
  @override
  @JsonKey(name: 'start_date')
  final DateTime? startDate;
  @override
  @JsonKey(name: 'due_date')
  final DateTime? dueDate;

  @override
  String toString() {
    return 'ProjectUpdateRequest(name: $name, description: $description, status: $status, priority: $priority, startDate: $startDate, dueDate: $dueDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProjectUpdateRequestImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    description,
    status,
    priority,
    startDate,
    dueDate,
  );

  /// Create a copy of ProjectUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProjectUpdateRequestImplCopyWith<_$ProjectUpdateRequestImpl>
  get copyWith =>
      __$$ProjectUpdateRequestImplCopyWithImpl<_$ProjectUpdateRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ProjectUpdateRequestImplToJson(this);
  }
}

abstract class _ProjectUpdateRequest implements ProjectUpdateRequest {
  const factory _ProjectUpdateRequest({
    required final String name,
    final String? description,
    @ProjectStatusConverter() final ProjectStatus? status,
    @ProjectPriorityConverter() final ProjectPriority? priority,
    @JsonKey(name: 'start_date') final DateTime? startDate,
    @JsonKey(name: 'due_date') final DateTime? dueDate,
  }) = _$ProjectUpdateRequestImpl;

  factory _ProjectUpdateRequest.fromJson(Map<String, dynamic> json) =
      _$ProjectUpdateRequestImpl.fromJson;

  @override
  String get name;
  @override
  String? get description;
  @override
  @ProjectStatusConverter()
  ProjectStatus? get status;
  @override
  @ProjectPriorityConverter()
  ProjectPriority? get priority;
  @override
  @JsonKey(name: 'start_date')
  DateTime? get startDate;
  @override
  @JsonKey(name: 'due_date')
  DateTime? get dueDate;

  /// Create a copy of ProjectUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProjectUpdateRequestImplCopyWith<_$ProjectUpdateRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ProjectPatchRequest _$ProjectPatchRequestFromJson(Map<String, dynamic> json) {
  return _ProjectPatchRequest.fromJson(json);
}

/// @nodoc
mixin _$ProjectPatchRequest {
  String? get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @ProjectStatusConverter()
  ProjectStatus? get status => throw _privateConstructorUsedError;
  @ProjectPriorityConverter()
  ProjectPriority? get priority => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_date')
  DateTime? get startDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'due_date')
  DateTime? get dueDate => throw _privateConstructorUsedError;

  /// Serializes this ProjectPatchRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProjectPatchRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProjectPatchRequestCopyWith<ProjectPatchRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProjectPatchRequestCopyWith<$Res> {
  factory $ProjectPatchRequestCopyWith(
    ProjectPatchRequest value,
    $Res Function(ProjectPatchRequest) then,
  ) = _$ProjectPatchRequestCopyWithImpl<$Res, ProjectPatchRequest>;
  @useResult
  $Res call({
    String? name,
    String? description,
    @ProjectStatusConverter() ProjectStatus? status,
    @ProjectPriorityConverter() ProjectPriority? priority,
    @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'due_date') DateTime? dueDate,
  });
}

/// @nodoc
class _$ProjectPatchRequestCopyWithImpl<$Res, $Val extends ProjectPatchRequest>
    implements $ProjectPatchRequestCopyWith<$Res> {
  _$ProjectPatchRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProjectPatchRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? description = freezed,
    Object? status = freezed,
    Object? priority = freezed,
    Object? startDate = freezed,
    Object? dueDate = freezed,
  }) {
    return _then(
      _value.copyWith(
            name: freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as ProjectStatus?,
            priority: freezed == priority
                ? _value.priority
                : priority // ignore: cast_nullable_to_non_nullable
                      as ProjectPriority?,
            startDate: freezed == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            dueDate: freezed == dueDate
                ? _value.dueDate
                : dueDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProjectPatchRequestImplCopyWith<$Res>
    implements $ProjectPatchRequestCopyWith<$Res> {
  factory _$$ProjectPatchRequestImplCopyWith(
    _$ProjectPatchRequestImpl value,
    $Res Function(_$ProjectPatchRequestImpl) then,
  ) = __$$ProjectPatchRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? name,
    String? description,
    @ProjectStatusConverter() ProjectStatus? status,
    @ProjectPriorityConverter() ProjectPriority? priority,
    @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'due_date') DateTime? dueDate,
  });
}

/// @nodoc
class __$$ProjectPatchRequestImplCopyWithImpl<$Res>
    extends _$ProjectPatchRequestCopyWithImpl<$Res, _$ProjectPatchRequestImpl>
    implements _$$ProjectPatchRequestImplCopyWith<$Res> {
  __$$ProjectPatchRequestImplCopyWithImpl(
    _$ProjectPatchRequestImpl _value,
    $Res Function(_$ProjectPatchRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProjectPatchRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? description = freezed,
    Object? status = freezed,
    Object? priority = freezed,
    Object? startDate = freezed,
    Object? dueDate = freezed,
  }) {
    return _then(
      _$ProjectPatchRequestImpl(
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: freezed == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as ProjectStatus?,
        priority: freezed == priority
            ? _value.priority
            : priority // ignore: cast_nullable_to_non_nullable
                  as ProjectPriority?,
        startDate: freezed == startDate
            ? _value.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        dueDate: freezed == dueDate
            ? _value.dueDate
            : dueDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProjectPatchRequestImpl implements _ProjectPatchRequest {
  const _$ProjectPatchRequestImpl({
    this.name,
    this.description,
    @ProjectStatusConverter() this.status,
    @ProjectPriorityConverter() this.priority,
    @JsonKey(name: 'start_date') this.startDate,
    @JsonKey(name: 'due_date') this.dueDate,
  });

  factory _$ProjectPatchRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProjectPatchRequestImplFromJson(json);

  @override
  final String? name;
  @override
  final String? description;
  @override
  @ProjectStatusConverter()
  final ProjectStatus? status;
  @override
  @ProjectPriorityConverter()
  final ProjectPriority? priority;
  @override
  @JsonKey(name: 'start_date')
  final DateTime? startDate;
  @override
  @JsonKey(name: 'due_date')
  final DateTime? dueDate;

  @override
  String toString() {
    return 'ProjectPatchRequest(name: $name, description: $description, status: $status, priority: $priority, startDate: $startDate, dueDate: $dueDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProjectPatchRequestImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    description,
    status,
    priority,
    startDate,
    dueDate,
  );

  /// Create a copy of ProjectPatchRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProjectPatchRequestImplCopyWith<_$ProjectPatchRequestImpl> get copyWith =>
      __$$ProjectPatchRequestImplCopyWithImpl<_$ProjectPatchRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ProjectPatchRequestImplToJson(this);
  }
}

abstract class _ProjectPatchRequest implements ProjectPatchRequest {
  const factory _ProjectPatchRequest({
    final String? name,
    final String? description,
    @ProjectStatusConverter() final ProjectStatus? status,
    @ProjectPriorityConverter() final ProjectPriority? priority,
    @JsonKey(name: 'start_date') final DateTime? startDate,
    @JsonKey(name: 'due_date') final DateTime? dueDate,
  }) = _$ProjectPatchRequestImpl;

  factory _ProjectPatchRequest.fromJson(Map<String, dynamic> json) =
      _$ProjectPatchRequestImpl.fromJson;

  @override
  String? get name;
  @override
  String? get description;
  @override
  @ProjectStatusConverter()
  ProjectStatus? get status;
  @override
  @ProjectPriorityConverter()
  ProjectPriority? get priority;
  @override
  @JsonKey(name: 'start_date')
  DateTime? get startDate;
  @override
  @JsonKey(name: 'due_date')
  DateTime? get dueDate;

  /// Create a copy of ProjectPatchRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProjectPatchRequestImplCopyWith<_$ProjectPatchRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProjectFilters _$ProjectFiltersFromJson(Map<String, dynamic> json) {
  return _ProjectFilters.fromJson(json);
}

/// @nodoc
mixin _$ProjectFilters {
  ProjectStatus? get status => throw _privateConstructorUsedError;
  String? get search => throw _privateConstructorUsedError;
  String? get ordering => throw _privateConstructorUsedError;

  /// Serializes this ProjectFilters to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProjectFilters
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProjectFiltersCopyWith<ProjectFilters> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProjectFiltersCopyWith<$Res> {
  factory $ProjectFiltersCopyWith(
    ProjectFilters value,
    $Res Function(ProjectFilters) then,
  ) = _$ProjectFiltersCopyWithImpl<$Res, ProjectFilters>;
  @useResult
  $Res call({ProjectStatus? status, String? search, String? ordering});
}

/// @nodoc
class _$ProjectFiltersCopyWithImpl<$Res, $Val extends ProjectFilters>
    implements $ProjectFiltersCopyWith<$Res> {
  _$ProjectFiltersCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProjectFilters
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = freezed,
    Object? search = freezed,
    Object? ordering = freezed,
  }) {
    return _then(
      _value.copyWith(
            status: freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as ProjectStatus?,
            search: freezed == search
                ? _value.search
                : search // ignore: cast_nullable_to_non_nullable
                      as String?,
            ordering: freezed == ordering
                ? _value.ordering
                : ordering // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProjectFiltersImplCopyWith<$Res>
    implements $ProjectFiltersCopyWith<$Res> {
  factory _$$ProjectFiltersImplCopyWith(
    _$ProjectFiltersImpl value,
    $Res Function(_$ProjectFiltersImpl) then,
  ) = __$$ProjectFiltersImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({ProjectStatus? status, String? search, String? ordering});
}

/// @nodoc
class __$$ProjectFiltersImplCopyWithImpl<$Res>
    extends _$ProjectFiltersCopyWithImpl<$Res, _$ProjectFiltersImpl>
    implements _$$ProjectFiltersImplCopyWith<$Res> {
  __$$ProjectFiltersImplCopyWithImpl(
    _$ProjectFiltersImpl _value,
    $Res Function(_$ProjectFiltersImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProjectFilters
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = freezed,
    Object? search = freezed,
    Object? ordering = freezed,
  }) {
    return _then(
      _$ProjectFiltersImpl(
        status: freezed == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as ProjectStatus?,
        search: freezed == search
            ? _value.search
            : search // ignore: cast_nullable_to_non_nullable
                  as String?,
        ordering: freezed == ordering
            ? _value.ordering
            : ordering // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProjectFiltersImpl implements _ProjectFilters {
  const _$ProjectFiltersImpl({this.status, this.search, this.ordering});

  factory _$ProjectFiltersImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProjectFiltersImplFromJson(json);

  @override
  final ProjectStatus? status;
  @override
  final String? search;
  @override
  final String? ordering;

  @override
  String toString() {
    return 'ProjectFilters(status: $status, search: $search, ordering: $ordering)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProjectFiltersImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.search, search) || other.search == search) &&
            (identical(other.ordering, ordering) ||
                other.ordering == ordering));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, status, search, ordering);

  /// Create a copy of ProjectFilters
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProjectFiltersImplCopyWith<_$ProjectFiltersImpl> get copyWith =>
      __$$ProjectFiltersImplCopyWithImpl<_$ProjectFiltersImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ProjectFiltersImplToJson(this);
  }
}

abstract class _ProjectFilters implements ProjectFilters {
  const factory _ProjectFilters({
    final ProjectStatus? status,
    final String? search,
    final String? ordering,
  }) = _$ProjectFiltersImpl;

  factory _ProjectFilters.fromJson(Map<String, dynamic> json) =
      _$ProjectFiltersImpl.fromJson;

  @override
  ProjectStatus? get status;
  @override
  String? get search;
  @override
  String? get ordering;

  /// Create a copy of ProjectFilters
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProjectFiltersImplCopyWith<_$ProjectFiltersImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
