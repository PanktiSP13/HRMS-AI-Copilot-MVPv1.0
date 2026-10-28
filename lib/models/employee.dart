import 'package:json_annotation/json_annotation.dart';

part 'employee.g.dart';

@JsonSerializable()
class EmployeeCreateRequest {
  @JsonKey(name: 'employee_code')
  final String employeeCode;

  final String name;
  final String email;
  final String role;
  final String? department;
  final String? phone;
  final String? address;

  @JsonKey(name: 'department_id')
  final int? departmentId;

  @JsonKey(name: 'manager_id')
  final int? managerId;

  const EmployeeCreateRequest({
    required this.employeeCode,
    required this.name,
    required this.email,
    required this.role,
    this.department,
    this.phone,
    this.address,
    this.departmentId,
    this.managerId,
  });

  factory EmployeeCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$EmployeeCreateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$EmployeeCreateRequestToJson(this);
}

@JsonSerializable()
class EmployeeUpdateRequest {
  final String name;
  final String email;
  final String role;
  final String? department;
  final String? phone;
  final String? address;

  @JsonKey(name: 'department_id')
  final int? departmentId;

  @JsonKey(name: 'manager_id')
  final int? managerId;

  const EmployeeUpdateRequest({
    required this.name,
    required this.email,
    required this.role,
    this.department,
    this.phone,
    this.address,
    this.departmentId,
    this.managerId,
  });

  factory EmployeeUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$EmployeeUpdateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$EmployeeUpdateRequestToJson(this);
}

@JsonSerializable()
class Employee {
  final int id;

  @JsonKey(name: 'employee_code')
  final String employeeCode;

  final String name;
  final String email;
  final String? phone;
  final String? address;
  final String role;
  final String? department;

  @JsonKey(name: 'department_id')
  final int? departmentId;

  @JsonKey(name: 'manager_id')
  final int? managerId;

  @JsonKey(name: 'manager_name')
  final String? managerName;

  @JsonKey(name: 'profile_image_url')
  final String? profileImageUrl;

  @JsonKey(name: 'is_active')
  final bool isActive;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const Employee({
    required this.id,
    required this.employeeCode,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    required this.role,
    this.department,
    this.departmentId,
    this.managerId,
    this.managerName,
    this.profileImageUrl,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Employee.fromJson(Map<String, dynamic> json) =>
      _$EmployeeFromJson(json);

  Employee copyWith({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? role,
    String? department,
    int? departmentId,
    int? managerId,
    String? managerName,
    String? profileImageUrl,
    bool? isActive,
    DateTime? updatedAt,
  }) {
    return Employee(
      id: id,
      employeeCode: employeeCode,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      role: role ?? this.role,
      department: department ?? this.department,
      departmentId: departmentId ?? this.departmentId,
      managerId: managerId ?? this.managerId,
      managerName: managerName ?? this.managerName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => _$EmployeeToJson(this);
}