// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_balance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeaveBalance _$LeaveBalanceFromJson(Map<String, dynamic> json) => LeaveBalance(
      id: (json['id'] as num).toInt(),
      employeeId: (json['employee_id'] as num).toInt(),
      year: (json['year'] as num).toInt(),
      annualLeave: (json['annual_leave'] as num).toDouble(),
      medicalLeave: (json['medical_leave'] as num).toDouble(),
      casualLeave: (json['casual_leave'] as num).toDouble(),
      annualUsed: (json['annual_used'] as num).toDouble(),
      medicalUsed: (json['medical_used'] as num).toDouble(),
      casualUsed: (json['casual_used'] as num).toDouble(),
      carryForward: (json['carry_forward'] as num).toDouble(),
    );

Map<String, dynamic> _$LeaveBalanceToJson(LeaveBalance instance) =>
    <String, dynamic>{
      'id': instance.id,
      'employee_id': instance.employeeId,
      'year': instance.year,
      'annual_leave': instance.annualLeave,
      'medical_leave': instance.medicalLeave,
      'casual_leave': instance.casualLeave,
      'annual_used': instance.annualUsed,
      'medical_used': instance.medicalUsed,
      'casual_used': instance.casualUsed,
      'carry_forward': instance.carryForward,
    };

LeaveBalanceUpdateRequest _$LeaveBalanceUpdateRequestFromJson(
        Map<String, dynamic> json) =>
    LeaveBalanceUpdateRequest(
      year: (json['year'] as num).toInt(),
      annualLeave: (json['annual_leave'] as num).toDouble(),
      medicalLeave: (json['medical_leave'] as num).toDouble(),
      casualLeave: (json['casual_leave'] as num).toDouble(),
      annualUsed: (json['annual_used'] as num?)?.toDouble() ?? 0,
      medicalUsed: (json['medical_used'] as num?)?.toDouble() ?? 0,
      casualUsed: (json['casual_used'] as num?)?.toDouble() ?? 0,
      carryForward: (json['carry_forward'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$LeaveBalanceUpdateRequestToJson(
        LeaveBalanceUpdateRequest instance) =>
    <String, dynamic>{
      'year': instance.year,
      'annual_leave': instance.annualLeave,
      'medical_leave': instance.medicalLeave,
      'casual_leave': instance.casualLeave,
      'annual_used': instance.annualUsed,
      'medical_used': instance.medicalUsed,
      'casual_used': instance.casualUsed,
      'carry_forward': instance.carryForward,
    };
