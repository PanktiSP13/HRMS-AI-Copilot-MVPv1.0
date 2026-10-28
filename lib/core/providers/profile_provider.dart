import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/employee.dart';
import '../../models/leave_balance.dart';
import '../../models/leave_request.dart';
import '../../models/profile.dart';
import '../../repositories/profile_repository.dart';
import 'app_providers.dart';

class ProfileState {
  final Employee? profile;
  final List<LeaveBalance> leaveBalances;
  final List<LeaveRequest> leaveRequests;
  final bool isLoading;
  final String? errorMessage;

  const ProfileState({
    this.profile,
    this.leaveBalances = const [],
    this.leaveRequests = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  ProfileState copyWith({
    Employee? profile,
    List<LeaveBalance>? leaveBalances,
    List<LeaveRequest>? leaveRequests,
    bool? isLoading,
    String? errorMessage,
    bool clearProfile = false,
    bool clearError = false,
  }) {
    return ProfileState(
      profile: clearProfile ? null : profile ?? this.profile,
      leaveBalances: leaveBalances ?? this.leaveBalances,
      leaveRequests: leaveRequests ?? this.leaveRequests,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileRepository _repository;

  ProfileNotifier({
    required ProfileRepository repository,
  })  : _repository = repository,
        super(const ProfileState());

  Future<void> loadProfile() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final profile = await _repository.getProfile();

      state = state.copyWith(
        profile: profile,
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

  Future<void> updateProfile(
    ProfileUpdateRequest request,
  ) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final profile = await _repository.updateProfile(request);

      state = state.copyWith(
        profile: profile,
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

  Future<void> uploadAvatar(
    MultipartFile file,
  ) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final profile = await _repository.uploadAvatar(file);

      state = state.copyWith(
        profile: profile,
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

  Future<void> loadLeaveBalances() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final balances = await _repository.getLeaveBalances();

      state = state.copyWith(
        leaveBalances: balances,
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

  Future<void> loadLeaveRequests() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final requests = await _repository.getLeaveRequests();

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

  Future<void> createLeaveRequest(
    LeaveRequestCreate request,
  ) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final leaveRequest = await _repository.createLeaveRequest(request);

      final requests = [leaveRequest, ...state.leaveRequests]
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

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

  Future<void> cancelLeaveRequest(int id) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      await _repository.cancelLeaveRequest(id);

      state = state.copyWith(
        leaveRequests: state.leaveRequests.where((request) => request.id != id).toList(),
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

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>(
  (ref) {
    return ProfileNotifier(
      repository: ref.watch(profileRepositoryProvider),
    );
  },
);
