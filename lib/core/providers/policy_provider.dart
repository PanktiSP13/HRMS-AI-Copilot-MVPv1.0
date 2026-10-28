import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/policy.dart';
import '../../repositories/policy_repository.dart';
import 'app_providers.dart';

class PolicyState {
  final List<Policy> policies;
  final Policy? selectedPolicy;
  final bool isLoading;
  final String? errorMessage;
  final bool isUploading;
  final bool isDownloading;

  const PolicyState({
    this.policies = const [],
    this.selectedPolicy,
    this.isLoading = false,
    this.errorMessage,
    this.isUploading = false,
    this.isDownloading = false,
  });

  PolicyState copyWith({
    List<Policy>? policies,
    Policy? selectedPolicy,
    bool? isLoading,
    String? errorMessage,
    bool clearSelectedPolicy = false,
    bool clearError = false,
    bool? isUploading,
    bool? isDownloading,
  }) {
    return PolicyState(
      policies: policies ?? this.policies,
      selectedPolicy: clearSelectedPolicy ? null : selectedPolicy ?? this.selectedPolicy,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isUploading: isUploading ?? this.isUploading,
      isDownloading: isDownloading ?? this.isDownloading,
    );
  }
}

class PolicyNotifier extends StateNotifier<PolicyState> {
  final PolicyRepository _repository;

  PolicyNotifier({
    required PolicyRepository repository,
  })  : _repository = repository,
        super(const PolicyState());

  Future<void> loadPolicies() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final policies = await _repository.getPolicies();
      policies.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      state = state.copyWith(
        policies: policies,
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

  Future<void> loadPolicy(int id) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSelectedPolicy: true,
    );

    try {
      final policy = await _repository.getPolicy(id);

      state = state.copyWith(
        selectedPolicy: policy,
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

  Future<void> createPolicy(
    PolicyCreateRequest request,
  ) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final policy = await _repository.createPolicy(request);

      state = state.copyWith(
        policies: [
          policy,
          ...state.policies,
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

  Future<void> updatePolicy(
    int id,
    PolicyUpdateRequest request,
  ) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final policy = await _repository.updatePolicy(id, request);

      final policies = state.policies.map((item) {
        return item.id == id ? policy : item;
      }).toList();

      state = state.copyWith(
        policies: policies,
        selectedPolicy: policy,
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

  Future<void> deletePolicy(int id) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      await _repository.deletePolicy(id);

      state = state.copyWith(
        policies: state.policies.where((policy) => policy.id != id).toList(),
        clearSelectedPolicy: true,
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

  Future<bool> uploadPolicy({
    required String name,
    required String category,
    required String version,
    required List<int> fileBytes,
    required String fileName,
  }) async {
    state = state.copyWith(
      isUploading: true,
      clearError: true,
    );

    try {
      await _repository.uploadPolicyPdf(
        name: name,
        category: category,
        version: version,
        fileBytes: fileBytes,
        fileName: fileName,
      );

      state = state.copyWith(
        isUploading: false,
        clearError: true,
      );

      await loadPolicies();
      return true;
    } catch (error) {
      state = state.copyWith(
        isUploading: false,
        errorMessage: error.toString(),
      );
      return false;
    }
  }

  Future<bool> downloadPolicy({
    required int policyId,
    required String fileName,
  }) async {
    state = state.copyWith(
      isDownloading: true,
      clearError: true,
    );

    try {
      await _repository.downloadPolicyPdf(
        policyId: policyId,
        fileName: fileName,
      );

      state = state.copyWith(
        isDownloading: false,
        clearError: true,
      );

      return true;
    } catch (error) {
      state = state.copyWith(
        isDownloading: false,
        errorMessage: error.toString(),
      );

      return false;
    }
  }
}

final policyProvider = StateNotifierProvider<PolicyNotifier, PolicyState>(
  (ref) {
    return PolicyNotifier(
      repository: ref.watch(policyRepositoryProvider),
    );
  },
);
