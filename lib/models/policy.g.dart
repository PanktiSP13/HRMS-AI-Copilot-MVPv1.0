// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'policy.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PolicyCreateRequest _$PolicyCreateRequestFromJson(Map<String, dynamic> json) =>
    PolicyCreateRequest(
      name: json['name'] as String,
      category: json['category'] as String,
      version: json['version'] as String,
      content: json['content'] as String,
    );

Map<String, dynamic> _$PolicyCreateRequestToJson(
        PolicyCreateRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'category': instance.category,
      'version': instance.version,
      'content': instance.content,
    };

PolicyUpdateRequest _$PolicyUpdateRequestFromJson(Map<String, dynamic> json) =>
    PolicyUpdateRequest(
      name: json['name'] as String,
      category: json['category'] as String,
      version: json['version'] as String,
      content: json['content'] as String,
      isActive: json['is_active'] as bool,
    );

Map<String, dynamic> _$PolicyUpdateRequestToJson(
        PolicyUpdateRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'category': instance.category,
      'version': instance.version,
      'content': instance.content,
      'is_active': instance.isActive,
    };

Policy _$PolicyFromJson(Map<String, dynamic> json) => Policy(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      category: json['category'] as String,
      version: json['version'] as String,
      content: json['content'] as String,
      pdfFileName: json['pdf_file_name'] as String?,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$PolicyToJson(Policy instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'version': instance.version,
      'content': instance.content,
      'pdf_file_name': instance.pdfFileName,
      'is_active': instance.isActive,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
