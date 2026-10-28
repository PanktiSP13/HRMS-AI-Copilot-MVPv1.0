// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmployeeCreateRequest _$EmployeeCreateRequestFromJson(
        Map<String, dynamic> json) =>
    EmployeeCreateRequest(
      employeeCode: json['employee_code'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      department: json['department'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      departmentId: (json['department_id'] as num?)?.toInt(),
      managerId: (json['manager_id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$EmployeeCreateRequestToJson(
        EmployeeCreateRequest instance) =>
    <String, dynamic>{
      'employee_code': instance.employeeCode,
      'name': instance.name,
      'email': instance.email,
      'role': instance.role,
      'department': instance.department,
      'phone': instance.phone,
      'address': instance.address,
      'department_id': instance.departmentId,
      'manager_id': instance.managerId,
    };

EmployeeUpdateRequest _$EmployeeUpdateRequestFromJson(
        Map<String, dynamic> json) =>
    EmployeeUpdateRequest(
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      department: json['department'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      departmentId: (json['department_id'] as num?)?.toInt(),
      managerId: (json['manager_id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$EmployeeUpdateRequestToJson(
        EmployeeUpdateRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'role': instance.role,
      'department': instance.department,
      'phone': instance.phone,
      'address': instance.address,
      'department_id': instance.departmentId,
      'manager_id': instance.managerId,
    };

Employee _$EmployeeFromJson(Map<String, dynamic> json) => Employee(
      id: (json['id'] as num).toInt(),
      employeeCode: json['employee_code'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      role: json['role'] as String,
      department: json['department'] as String?,
      departmentId: (json['department_id'] as num?)?.toInt(),
      managerId: (json['manager_id'] as num?)?.toInt(),
      managerName: json['manager_name'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$EmployeeToJson(Employee instance) => <String, dynamic>{
      'id': instance.id,
      'employee_code': instance.employeeCode,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'address': instance.address,
      'role': instance.role,
      'department': instance.department,
      'department_id': instance.departmentId,
      'manager_id': instance.managerId,
      'manager_name': instance.managerName,
      'profile_image_url': instance.profileImageUrl,
      'is_active': instance.isActive,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
