import 'package:dio/dio.dart';
import 'package:hrms_ai_copilot/common/utils.dart';

import '../core/network/api_client.dart';
import '../core/network/api_constants.dart';
import '../models/employee.dart';
import '../models/leave_balance.dart';

class EmployeeRepository {
  final ApiClient _apiClient;

  EmployeeRepository({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  Future<List<Employee>> getEmployees() async {
    final response = await _apiClient.get(
      ApiRoutes.employees,
    );

    return Utils().toList(response.data).map(Employee.fromJson).toList();
  }

  Future<Employee> getEmployee(
    int id,
  ) async {
    final response = await _apiClient.get(
      ApiRoutes.employee(id),
    );

    return Employee.fromJson(
      Utils().toMap(response.data),
    );
  }

  Future<Employee> createEmployee(
    EmployeeCreateRequest request,
  ) async {
    final response = await _apiClient.post(
      ApiRoutes.employees,
      data: request.toJson(),
    );

    return Employee.fromJson(
      Utils().toMap(response.data),
    );
  }

  Future<Employee> updateEmployee(
    int id,
    EmployeeUpdateRequest request,
  ) async {
    final response = await _apiClient.put(
      ApiRoutes.employee(id),
      data: request.toJson(),
    );

    return Employee.fromJson(
      Utils().toMap(response.data),
    );
  }

  Future<void> deleteEmployee(
    int id,
  ) async {
    await _apiClient.delete(
      ApiRoutes.employee(id),
    );
  }

  Future<Employee> uploadEmployeeAvatar(
    int id,
    MultipartFile file,
  ) async {
    final formData = FormData.fromMap({
      ApiMultipartKeys.file: file,
    });

    final response = await _apiClient.upload(
      ApiRoutes.employeeAvatar(id),
      data: formData,
    );

    return Employee.fromJson(
      Utils().toMap(response.data),
    );
  }

  Future<LeaveBalance> getEmployeeLeaveBalance(
    int employeeId,
  ) async {
    final response = await _apiClient.get(
      ApiRoutes.employeeLeaveBalances(employeeId),
    );

    return LeaveBalance.fromJson(
      Utils().toMap(response.data),
    );
  }

  Future<LeaveBalance> updateEmployeeLeaveBalance(
    int employeeId,
    LeaveBalanceUpdateRequest request,
  ) async {
    final response = await _apiClient.put(
      ApiRoutes.employeeLeaveBalances(employeeId),
      data: request.toJson(),
    );

    return LeaveBalance.fromJson(
      Utils().toMap(response.data),
    );
  }
}
