import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/employee.dart';
import '../../models/leave_balance.dart';
import '../../repositories/employee_repository.dart';
import 'app_providers.dart';

class EmployeeState {
  final List<Employee> employees;
  final Employee? selectedEmployee;
  final LeaveBalance? selectedEmployeeLeaveBalance;
  final bool isLoading;
  final String? errorMessage;

  const EmployeeState({
    this.employees = const [],
    this.selectedEmployee,
    this.selectedEmployeeLeaveBalance,
    this.isLoading = false,
    this.errorMessage,
  });

  EmployeeState copyWith({
    List<Employee>? employees,
    Employee? selectedEmployee,
    LeaveBalance? selectedEmployeeLeaveBalance,
    bool? isLoading,
    String? errorMessage,
    bool clearSelectedEmployee = false,
    bool clearLeaveBalance = false,
    bool clearError = false,
  }) {
    return EmployeeState(
      employees: employees ?? this.employees,
      selectedEmployee: clearSelectedEmployee ? null : selectedEmployee ?? this.selectedEmployee,
      selectedEmployeeLeaveBalance: clearLeaveBalance ? null : selectedEmployeeLeaveBalance ?? this.selectedEmployeeLeaveBalance,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class EmployeeNotifier extends StateNotifier<EmployeeState> {
  final EmployeeRepository _repository;

  EmployeeNotifier({
    required EmployeeRepository repository,
  })  : _repository = repository,
        super(const EmployeeState());

  Future<void> loadEmployees() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final employees = await _repository.getEmployees();
      final activeIds = employees.map((employee) => employee.id).toSet();
      final cachedInactive = state.employees.where((employee) => !employee.isActive && !activeIds.contains(employee.id));
      employees.addAll(cachedInactive);
      employees.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      state = state.copyWith(
        employees: employees,
        isLoading: false,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> loadEmployee(int id) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSelectedEmployee: true,
      clearLeaveBalance: true,
    );

    try {
      final employee = await _repository.getEmployee(id);

      state = state.copyWith(
        selectedEmployee: employee,
        isLoading: false,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> createEmployee(
    EmployeeCreateRequest request,
  ) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final employee = await _repository.createEmployee(request);

      state = state.copyWith(
        employees: [
          employee,
          ...state.employees,
        ],
        isLoading: false,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> updateEmployee(
    int id,
    EmployeeUpdateRequest request,
  ) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final employee = await _repository.updateEmployee(id, request);

      final employees = state.employees.map((item) {
        return item.id == id ? employee : item;
      }).toList();

      state = state.copyWith(
        employees: employees,
        selectedEmployee: employee,
        isLoading: false,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> deleteEmployee(int id) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      await _repository.deleteEmployee(id);
      final employees = state.employees.map((employee) {
        return employee.id == id
            ? employee.copyWith(isActive: false, updatedAt: DateTime.now())
            : employee;
      }).toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      final updatedEmployee = employees.where((employee) => employee.id == id).toList();
      state = state.copyWith(
        employees: employees,
        selectedEmployee: updatedEmployee.isEmpty ? null : updatedEmployee.first,
        clearLeaveBalance: true,
        isLoading: false,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> uploadEmployeeAvatar(
    int id,
    MultipartFile file,
  ) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final employee = await _repository.uploadEmployeeAvatar(id, file);

      final employees = state.employees.map((item) {
        return item.id == id ? employee : item;
      }).toList();

      state = state.copyWith(
        employees: employees,
        selectedEmployee: employee,
        isLoading: false,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> loadEmployeeLeaveBalance(
    int employeeId,
  ) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final balance = await _repository.getEmployeeLeaveBalance(employeeId);

      state = state.copyWith(
        selectedEmployeeLeaveBalance: balance,
        isLoading: false,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> updateEmployeeLeaveBalance(
    int employeeId,
    LeaveBalanceUpdateRequest request,
  ) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final balance = await _repository.updateEmployeeLeaveBalance(
        employeeId,
        request,
      );

      state = state.copyWith(
        selectedEmployeeLeaveBalance: balance,
        isLoading: false,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(
      clearError: true,
    );
  }
}

final employeeProvider = StateNotifierProvider<EmployeeNotifier, EmployeeState>(
  (ref) {
    return EmployeeNotifier(
      repository: ref.watch(employeeRepositoryProvider),
    );
  },
);
