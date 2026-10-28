import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/department.dart';
import '../../repositories/department_repository.dart';
import 'app_providers.dart';

class DepartmentState {
  final List<Department> departments;
  final Department? selectedDepartment;
  final bool isLoading;
  final String? errorMessage;

  const DepartmentState({
    this.departments = const [],
    this.selectedDepartment,
    this.isLoading = false,
    this.errorMessage,
  });

  DepartmentState copyWith({
    List<Department>? departments,
    Department? selectedDepartment,
    bool? isLoading,
    String? errorMessage,
    bool clearSelectedDepartment = false,
    bool clearError = false,
  }) {
    return DepartmentState(
      departments: departments ?? this.departments,
      selectedDepartment: clearSelectedDepartment ? null : selectedDepartment ?? this.selectedDepartment,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class DepartmentNotifier extends StateNotifier<DepartmentState> {
  final DepartmentRepository _repository;

  DepartmentNotifier({
    required DepartmentRepository repository,
  })  : _repository = repository,
        super(const DepartmentState());

  Future<void> loadDepartments() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final departments = await _repository.getDepartments();
      departments.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      state = state.copyWith(
        departments: departments,
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

  Future<void> loadDepartment(int id) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSelectedDepartment: true,
    );

    try {
      final department = await _repository.getDepartment(id);

      state = state.copyWith(
        selectedDepartment: department,
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

  Future<void> createDepartment(
    DepartmentCreateRequest request,
  ) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final department = await _repository.createDepartment(request);

      state = state.copyWith(
        departments: [
          department,
          ...state.departments,
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

  Future<void> updateDepartment(
    int id,
    DepartmentUpdateRequest request,
  ) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final department = await _repository.updateDepartment(id, request);

      final departments = state.departments.map((item) {
        return item.id == id ? department : item;
      }).toList();

      state = state.copyWith(
        departments: departments,
        selectedDepartment: department,
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

  Future<void> deleteDepartment(int id) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      await _repository.deleteDepartment(id);

      state = state.copyWith(
        departments: state.departments.where((department) => department.id != id).toList(),
        clearSelectedDepartment: true,
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

final departmentProvider = StateNotifierProvider<DepartmentNotifier, DepartmentState>(
  (ref) {
    return DepartmentNotifier(
      repository: ref.watch(
        departmentRepositoryProvider,
      ),
    );
  },
);
