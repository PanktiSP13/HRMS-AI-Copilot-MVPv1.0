import 'package:json_annotation/json_annotation.dart';

part 'leave_balance.g.dart';

@JsonSerializable()
class LeaveBalance {
  final int id;

  @JsonKey(name: 'employee_id')
  final int employeeId;

  final int year;

  @JsonKey(name: 'annual_leave')
  final double annualLeave;

  @JsonKey(name: 'medical_leave')
  final double medicalLeave;

  @JsonKey(name: 'casual_leave')
  final double casualLeave;

  @JsonKey(name: 'annual_used')
  final double annualUsed;

  @JsonKey(name: 'medical_used')
  final double medicalUsed;

  @JsonKey(name: 'casual_used')
  final double casualUsed;

  @JsonKey(name: 'carry_forward')
  final double carryForward;

  const LeaveBalance({
    required this.id,
    required this.employeeId,
    required this.year,
    required this.annualLeave,
    required this.medicalLeave,
    required this.casualLeave,
    required this.annualUsed,
    required this.medicalUsed,
    required this.casualUsed,
    required this.carryForward,
  });

  factory LeaveBalance.fromJson(Map<String, dynamic> json) => _$LeaveBalanceFromJson(json);

  Map<String, dynamic> toJson() => _$LeaveBalanceToJson(this);
}

@JsonSerializable()
class LeaveBalanceUpdateRequest {
  final int year;

  @JsonKey(name: 'annual_leave')
  final double annualLeave;
  @JsonKey(name: 'medical_leave')
  final double medicalLeave;
  @JsonKey(name: 'casual_leave')
  final double casualLeave;
  @JsonKey(name: 'annual_used')
  final double annualUsed;
  @JsonKey(name: 'medical_used')
  final double medicalUsed;
  @JsonKey(name: 'casual_used')
  final double casualUsed;
  @JsonKey(name: 'carry_forward')
  final double carryForward;

  const LeaveBalanceUpdateRequest({
    required this.year,
    required this.annualLeave,
    required this.medicalLeave,
    required this.casualLeave,
    this.annualUsed = 0,
    this.medicalUsed = 0,
    this.casualUsed = 0,
    this.carryForward = 0,
  });

  factory LeaveBalanceUpdateRequest.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$LeaveBalanceUpdateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LeaveBalanceUpdateRequestToJson(this);
}
