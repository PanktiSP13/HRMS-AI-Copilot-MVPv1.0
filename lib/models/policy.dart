import 'package:json_annotation/json_annotation.dart';

part 'policy.g.dart';

@JsonSerializable()
class PolicyCreateRequest {
  final String name;
  final String category;
  final String version;
  final String content;

  const PolicyCreateRequest({
    required this.name,
    required this.category,
    required this.version,
    required this.content,
  });

  factory PolicyCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$PolicyCreateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PolicyCreateRequestToJson(this);
}

@JsonSerializable()
class PolicyUpdateRequest {
  final String name;
  final String category;
  final String version;

  final String content;

  @JsonKey(name: 'is_active')
  final bool isActive;

  const PolicyUpdateRequest({
    required this.name,
    required this.category,
    required this.version,
    required this.content,
    required this.isActive,
  });

  factory PolicyUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$PolicyUpdateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PolicyUpdateRequestToJson(this);
}

@JsonSerializable()
class Policy {
  final int id;
  final String name;
  final String category;
  final String version;
  final String content;

  @JsonKey(name: 'pdf_file_name')
  final String? pdfFileName;

  @JsonKey(name: 'is_active')
  final bool isActive;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const Policy({
    required this.id,
    required this.name,
    required this.category,
    required this.version,
    required this.content,
    this.pdfFileName,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Policy.fromJson(Map<String, dynamic> json) =>
      _$PolicyFromJson(json);

  Map<String, dynamic> toJson() => _$PolicyToJson(this);
}
