// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeaveRequestCreate _$LeaveRequestCreateFromJson(Map<String, dynamic> json) =>
    LeaveRequestCreate(
      leaveType: json['leave_type'] as String,
      startDate: _dateFromJson(json['start_date'] as String),
      endDate: _dateFromJson(json['end_date'] as String),
      reason: json['reason'] as String?,
      comment: json['comment'] as String?,
    );

Map<String, dynamic> _$LeaveRequestCreateToJson(LeaveRequestCreate instance) =>
    <String, dynamic>{
      'leave_type': instance.leaveType,
      'start_date': _dateToJson(instance.startDate),
      'end_date': _dateToJson(instance.endDate),
      'reason': instance.reason,
      'comment': instance.comment,
    };

LeaveRequestStatusUpdate _$LeaveRequestStatusUpdateFromJson(
        Map<String, dynamic> json) =>
    LeaveRequestStatusUpdate(
      status: json['status'] as String,
      rejectionReason: json['rejection_reason'] as String?,
      comment: json['comment'] as String?,
    );

Map<String, dynamic> _$LeaveRequestStatusUpdateToJson(
        LeaveRequestStatusUpdate instance) =>
    <String, dynamic>{
      'status': instance.status,
      'rejection_reason': instance.rejectionReason,
      'comment': instance.comment,
    };

LeaveRequest _$LeaveRequestFromJson(Map<String, dynamic> json) => LeaveRequest(
      id: (json['id'] as num).toInt(),
      employeeId: (json['employee_id'] as num).toInt(),
      leaveType: json['leave_type'] as String,
      startDate: _dateFromJson(json['start_date'] as String),
      endDate: _dateFromJson(json['end_date'] as String),
      reason: json['reason'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
      status: json['status'] as String,
      approvedBy: (json['approved_by'] as num?)?.toInt(),
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$LeaveRequestToJson(LeaveRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'employee_id': instance.employeeId,
      'leave_type': instance.leaveType,
      'start_date': _dateToJson(instance.startDate),
      'end_date': _dateToJson(instance.endDate),
      'reason': instance.reason,
      'rejection_reason': instance.rejectionReason,
      'status': instance.status,
      'approved_by': instance.approvedBy,
      'comment': instance.comment,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
