import 'package:json_annotation/json_annotation.dart';

part 'leave_request.g.dart';

String _dateToJson(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');

  return '$year-$month-$day';
}

DateTime _dateFromJson(String value) {
  return DateTime.parse(value);
}

@JsonSerializable()
class LeaveRequestCreate {
  @JsonKey(
    name: 'leave_type',
  )
  final String leaveType;

  @JsonKey(
    name: 'start_date',
    toJson: _dateToJson,
    fromJson: _dateFromJson,
  )
  final DateTime startDate;

  @JsonKey(
    name: 'end_date',
    toJson: _dateToJson,
    fromJson: _dateFromJson,
  )
  final DateTime endDate;

  final String? reason;
  final String? comment;

  const LeaveRequestCreate({
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    this.reason,
    this.comment,
  });

  factory LeaveRequestCreate.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$LeaveRequestCreateFromJson(json);

  Map<String, dynamic> toJson() => _$LeaveRequestCreateToJson(this);
}

@JsonSerializable()
class LeaveRequestStatusUpdate {
  final String status;

  @JsonKey(name: 'rejection_reason')
  final String? rejectionReason;

  final String? comment;

  const LeaveRequestStatusUpdate({
    required this.status,
    this.rejectionReason,
    this.comment,
  });

  factory LeaveRequestStatusUpdate.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$LeaveRequestStatusUpdateFromJson(json);

  Map<String, dynamic> toJson() => _$LeaveRequestStatusUpdateToJson(this);
}

@JsonSerializable()
class LeaveRequest {
  final int id;

  @JsonKey(name: 'employee_id')
  final int employeeId;

  @JsonKey(name: 'leave_type')
  final String leaveType;

  @JsonKey(
    name: 'start_date',
    toJson: _dateToJson,
    fromJson: _dateFromJson,
  )
  final DateTime startDate;

  @JsonKey(
    name: 'end_date',
    toJson: _dateToJson,
    fromJson: _dateFromJson,
  )
  final DateTime endDate;

  final String? reason;

  @JsonKey(name: 'rejection_reason')
  final String? rejectionReason;

  final String status;

  @JsonKey(name: 'approved_by')
  final int? approvedBy;

  final String? comment;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const LeaveRequest({
    required this.id,
    required this.employeeId,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    this.reason,
    this.rejectionReason,
    required this.status,
    this.approvedBy,
    this.comment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LeaveRequest.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$LeaveRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LeaveRequestToJson(this);
}
