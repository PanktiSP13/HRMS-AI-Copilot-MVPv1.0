import 'package:hrms_ai_copilot/common/utils.dart';

import '../core/network/api_client.dart';
import '../core/network/api_constants.dart';
import '../models/department.dart';

class DepartmentRepository {
  final ApiClient _apiClient;

  DepartmentRepository({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  Future<List<Department>> getDepartments() async {
    final response = await _apiClient.get(
      ApiRoutes.departments,
    );

    return Utils().toList(response.data).map(Department.fromJson).toList();
  }

  Future<Department> getDepartment(
    int id,
  ) async {
    final response = await _apiClient.get(
      ApiRoutes.department(id),
    );

    return Department.fromJson(
      Utils().toMap(response.data),
    );
  }

  Future<Department> createDepartment(
    DepartmentCreateRequest request,
  ) async {
    final response = await _apiClient.post(
      ApiRoutes.departments,
      data: request.toJson(),
    );

    return Department.fromJson(
      Utils().toMap(response.data),
    );
  }

  Future<Department> updateDepartment(
    int id,
    DepartmentUpdateRequest request,
  ) async {
    final response = await _apiClient.put(
      ApiRoutes.department(id),
      data: request.toJson(),
    );

    return Department.fromJson(
      Utils().toMap(response.data),
    );
  }

  Future<void> deleteDepartment(
    int id,
  ) async {
    await _apiClient.delete(
      ApiRoutes.department(id),
    );
  }
}
