import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../repositories/ai_chat_repository.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/department_repository.dart';
import '../../repositories/employee_repository.dart';
import '../../repositories/leave_repository.dart';
import '../../repositories/policy_repository.dart';
import '../../repositories/profile_repository.dart';
import '../network/api_client.dart';
import '../storage/token_storage.dart';

final tokenStorageProvider = Provider<TokenStorage>(
  (ref) {
    return const TokenStorage();
  },
);

final apiClientProvider = Provider<ApiClient>(
  (ref) {
    return ApiClient(
      tokenStorage: ref.watch(tokenStorageProvider),
    );
  },
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) {
    return AuthRepository(
      apiClient: ref.watch(apiClientProvider),
      tokenStorage: ref.watch(tokenStorageProvider),
    );
  },
);

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) {
    return ProfileRepository(
      apiClient: ref.watch(apiClientProvider),
    );
  },
);

final employeeRepositoryProvider = Provider<EmployeeRepository>(
  (ref) {
    return EmployeeRepository(
      apiClient: ref.watch(apiClientProvider),
    );
  },
);

final leaveRepositoryProvider = Provider<LeaveRepository>(
  (ref) {
    return LeaveRepository(
      apiClient: ref.watch(apiClientProvider),
    );
  },
);

final departmentRepositoryProvider = Provider<DepartmentRepository>(
  (ref) {
    return DepartmentRepository(
      apiClient: ref.watch(apiClientProvider),
    );
  },
);

final policyRepositoryProvider = Provider<PolicyRepository>(
  (ref) {
    return PolicyRepository(
      apiClient: ref.watch(apiClientProvider),
    );
  },
);

/// Repository for server-persisted AI conversations.
final aiChatRepositoryProvider = Provider<AiChatRepository>((ref) {
  return AiChatRepository(apiClient: ref.watch(apiClientProvider));
});
