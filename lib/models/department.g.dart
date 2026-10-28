// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'department.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DepartmentCreateRequest _$DepartmentCreateRequestFromJson(
        Map<String, dynamic> json) =>
    DepartmentCreateRequest(
      name: json['name'] as String,
      code: json['code'] as String,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$DepartmentCreateRequestToJson(
        DepartmentCreateRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'code': instance.code,
      'description': instance.description,
    };

DepartmentUpdateRequest _$DepartmentUpdateRequestFromJson(
        Map<String, dynamic> json) =>
    DepartmentUpdateRequest(
      name: json['name'] as String,
      code: json['code'] as String,
      description: json['description'] as String?,
      isActive: json['is_active'] as bool,
    );

Map<String, dynamic> _$DepartmentUpdateRequestToJson(
        DepartmentUpdateRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'code': instance.code,
      'description': instance.description,
      'is_active': instance.isActive,
    };

Department _$DepartmentFromJson(Map<String, dynamic> json) => Department(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      code: json['code'] as String,
      description: json['description'] as String?,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$DepartmentToJson(Department instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'code': instance.code,
      'description': instance.description,
      'is_active': instance.isActive,
      'created_at': instance.createdAt.toIso8601String(),
    };
