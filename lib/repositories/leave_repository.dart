import 'package:hrms_ai_copilot/common/utils.dart';

import '../core/network/api_client.dart';
import '../core/network/api_constants.dart';
import '../models/leave_request.dart';

class LeaveRepository {
  final ApiClient _apiClient;

  LeaveRepository({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  Future<List<LeaveRequest>> getLeaveRequests() async {
    final response = await _apiClient.get(
      ApiRoutes.leaveRequests,
    );

    return Utils().toList(response.data).map(LeaveRequest.fromJson).toList();
  }

  Future<LeaveRequest> getLeaveRequest(
    int id,
  ) async {
    final response = await _apiClient.get(
      ApiRoutes.leaveRequest(id),
    );

    return LeaveRequest.fromJson(
      Utils().toMap(response.data),
    );
  }

  Future<LeaveRequest> updateLeaveRequestStatus(
    int id,
    LeaveRequestStatusUpdate request,
  ) async {
    final response = await _apiClient.patch(
      ApiRoutes.leaveRequestStatus(id),
      data: request.toJson(),
    );

    return LeaveRequest.fromJson(
      Utils().toMap(response.data),
    );
  }
}
