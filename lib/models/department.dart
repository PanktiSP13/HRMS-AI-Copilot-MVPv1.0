import 'package:json_annotation/json_annotation.dart';

part 'department.g.dart';

@JsonSerializable()
class DepartmentCreateRequest {
  final String name;
  final String code;
  final String? description;

  const DepartmentCreateRequest({
    required this.name,
    required this.code,
    this.description,
  });

  factory DepartmentCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$DepartmentCreateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$DepartmentCreateRequestToJson(this);
}

@JsonSerializable()
class DepartmentUpdateRequest {
  final String name;
  final String code;
  final String? description;

  @JsonKey(name: 'is_active')
  final bool isActive;

  const DepartmentUpdateRequest({
    required this.name,
    required this.code,
    this.description,
    required this.isActive,
  });

  factory DepartmentUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$DepartmentUpdateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$DepartmentUpdateRequestToJson(this);
}

@JsonSerializable()
class Department {
  final int id;
  final String name;
  final String code;
  final String? description;

  @JsonKey(name: 'is_active')
  final bool isActive;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const Department({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    required this.isActive,
    required this.createdAt,
  });

  factory Department.fromJson(Map<String, dynamic> json) =>
      _$DepartmentFromJson(json);

  Map<String, dynamic> toJson() => _$DepartmentToJson(this);
}