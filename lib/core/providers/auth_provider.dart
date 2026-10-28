import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_exception.dart';
import '../../models/auth.dart';
import '../../repositories/auth_repository.dart';
import 'app_providers.dart';
import 'department_provider.dart';
import 'employee_provider.dart';
import 'leave_provider.dart';
import 'policy_provider.dart';
import 'profile_provider.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthState {
  final AuthStatus status;
  final MeResponse? user;
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
  });

  const AuthState.initial()
      : status = AuthStatus.initial,
        user = null,
        errorMessage = null;

  AuthState copyWith({
    AuthStatus? status,
    MeResponse? user,
    String? errorMessage,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : user ?? this.user,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final Ref _ref;

  AuthNotifier({
    required AuthRepository authRepository,
    required Ref ref,
  })  : _authRepository = authRepository,
        _ref = ref,
        super(const AuthState.initial());

  void _clearSessionData() {
    _ref.invalidate(profileProvider);
    _ref.invalidate(employeeProvider);
    _ref.invalidate(leaveProvider);
    _ref.invalidate(departmentProvider);
    _ref.invalidate(policyProvider);
  }

  Future<void> initialize() async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);

    try {
      final isLoggedIn = await _authRepository.isLoggedIn();

      if (!isLoggedIn) {
        _clearSessionData();
        state = state.copyWith(status: AuthStatus.unauthenticated, clearUser: true);
        return;
      }

      final user = await _authRepository.getCurrentUser();
      _clearSessionData();
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        clearError: true,
      );
    } catch (error) {
      await _authRepository.clearLocalSession();
      _clearSessionData();
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        clearUser: true,
        errorMessage: _getErrorMessage(error),
      );
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);

    try {
      await _authRepository.login(email: email, password: password);
      final user = await _authRepository.getCurrentUser();
      _clearSessionData();

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: AuthStatus.error,
        clearUser: true,
        errorMessage: _getErrorMessage(error),
      );
    }
  }

  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);

    try {
      await _authRepository.logout();
    } catch (_) {
      // Local credentials are cleared by AuthRepository even when the backend
      // logout call fails. The user should still leave the authenticated flow.
    } finally {
      _clearSessionData();
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        clearUser: true,
        clearError: true,
      );
    }
  }

  String _getErrorMessage(Object error) {
    if (error is ApiException) return error.message;
    return error.toString();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(
    authRepository: ref.watch(authRepositoryProvider),
    ref: ref,
  ),
);
