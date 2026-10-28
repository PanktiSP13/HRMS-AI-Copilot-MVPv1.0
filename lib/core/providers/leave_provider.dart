import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/leave_request.dart';
import '../../repositories/leave_repository.dart';
import 'app_providers.dart';

class LeaveState {
  final List<LeaveRequest> leaveRequests;
  final LeaveRequest? selectedLeaveRequest;
  final bool isLoading;
  final String? errorMessage;

  const LeaveState({
    this.leaveRequests = const [],
    this.selectedLeaveRequest,
    this.isLoading = false,
    this.errorMessage,
  });

  LeaveState copyWith({
    List<LeaveRequest>? leaveRequests,
    LeaveRequest? selectedLeaveRequest,
    bool? isLoading,
    String? errorMessage,
    bool clearSelectedLeaveRequest = false,
    bool clearError = false,
  }) {
    return LeaveState(
      leaveRequests: leaveRequests ?? this.leaveRequests,
      selectedLeaveRequest: clearSelectedLeaveRequest ? null : selectedLeaveRequest ?? this.selectedLeaveRequest,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class LeaveNotifier extends StateNotifier<LeaveState> {
  final LeaveRepository _repository;

  LeaveNotifier({
    required LeaveRepository repository,
  })  : _repository = repository,
        super(const LeaveState());

  Future<void> loadLeaveRequests() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final requests = await _repository.getLeaveRequests();
      requests.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      state = state.copyWith(
        leaveRequests: requests,
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

  Future<void> loadLeaveRequest(int id) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSelectedLeaveRequest: true,
    );

    try {
      final request = await _repository.getLeaveRequest(id);

      state = state.copyWith(
        selectedLeaveRequest: request,
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

  Future<void> updateLeaveRequestStatus(
    int id,
    LeaveRequestStatusUpdate request,
  ) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final updatedRequest = await _repository.updateLeaveRequestStatus(
        id,
        request,
      );

      final requests = state.leaveRequests.map((item) {
        return item.id == id ? updatedRequest : item;
      }).toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      state = state.copyWith(
        leaveRequests: requests,
        selectedLeaveRequest: updatedRequest,
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

final leaveProvider = StateNotifierProvider<LeaveNotifier, LeaveState>(
  (ref) {
    return LeaveNotifier(
      repository: ref.watch(leaveRepositoryProvider),
    );
  },
);
