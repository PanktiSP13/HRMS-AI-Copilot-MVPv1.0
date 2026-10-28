import 'package:dio/dio.dart';
import 'package:hrms_ai_copilot/common/utils.dart';

import '../core/network/api_client.dart';
import '../core/network/api_constants.dart';
import '../models/employee.dart';
import '../models/leave_balance.dart';
import '../models/leave_request.dart';
import '../models/profile.dart';

class ProfileRepository {
  final ApiClient _apiClient;

  ProfileRepository({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  Future<Employee> getProfile() async {
    final response = await _apiClient.get(
      ApiRoutes.profile,
    );

    return Employee.fromJson(
      Utils().toMap(response.data),
    );
  }

  Future<Employee> updateProfile(
    ProfileUpdateRequest request,
  ) async {
    final response = await _apiClient.patch(
      ApiRoutes.profile,
      data: request.toJson(),
    );

    return Employee.fromJson(
      Utils().toMap(response.data),
    );
  }

  Future<Employee> uploadAvatar(
    MultipartFile file,
  ) async {
    final formData = FormData.fromMap({
      ApiMultipartKeys.file: file,
    });

    final response = await _apiClient.upload(
      ApiRoutes.profileAvatar,
      data: formData,
    );

    return Employee.fromJson(
      Utils().toMap(response.data),
    );
  }

  Future<List<LeaveBalance>> getLeaveBalances() async {
    final response = await _apiClient.get(
      ApiRoutes.profileLeaveBalances,
    );

    return Utils().toList(response.data).map(LeaveBalance.fromJson).toList();
  }

  Future<List<LeaveRequest>> getLeaveRequests() async {
    final response = await _apiClient.get(
      ApiRoutes.profileLeaveRequests,
    );

    return Utils().toList(response.data).map(LeaveRequest.fromJson).toList();
  }

  Future<LeaveRequest> createLeaveRequest(
    LeaveRequestCreate request,
  ) async {
    final response = await _apiClient.post(
      ApiRoutes.profileLeaveRequests,
      data: request.toJson(),
    );

    return LeaveRequest.fromJson(
      Utils().toMap(response.data),
    );
  }

  Future<void> cancelLeaveRequest(
    int id,
  ) async {
    await _apiClient.delete(
      ApiRoutes.profileLeaveRequest(id),
    );
  }
}
