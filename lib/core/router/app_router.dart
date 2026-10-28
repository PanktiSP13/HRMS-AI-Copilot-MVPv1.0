import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../common/widgets/app_desktop_shell.dart';
import '../../features/auth/auth_screen.dart';
import '../../features/chat/chat_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/departments/department_detail_screen.dart';
import '../../features/departments/department_form_screen.dart';
import '../../features/departments/departments_screen.dart';
import '../../features/employees/employee_detail_screen.dart';
import '../../features/employees/employee_form_screen.dart';
import '../../features/employees/employees_screen.dart';
import '../../features/leave/leave_detail_screen.dart';
import '../../features/leave/leave_form_screen.dart';
import '../../features/leave/leave_screen.dart';
import '../../features/policies/policies_screen.dart';
import '../../features/policies/policy_detail_screen.dart';
import '../../features/policies/policy_form_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../providers/auth_provider.dart';

/// Centralized route paths string constants across the application.
class AppRoutes {
  AppRoutes._();

  static const auth = '/auth';
  static const dashboard = '/dashboard';
  static const profile = '/profile';
  static const employees = '/employees';
  static const leave = '/leave';
  static const departments = '/departments';
  static const policies = '/policies';
  static const chat = '/chat';

  static const employeeCreate = '$employees/create';
  static String employeeDetails(int id) => '$employees/$id';
  static String employeeEdit(int id) => '$employees/$id/edit';

  static const leaveApply = '$leave/apply';
  static String leaveDetails(int id) => '$leave/$id';

  static const departmentCreate = '$departments/create';
  static String departmentDetails(int id) => '$departments/$id';
  static String departmentEdit(int id) => '$departments/$id/edit';

  static const policyCreate = '$policies/create';
  static String policyDetails(int id) => '$policies/$id';
  static String policyEdit(int id) => '$policies/$id/edit';
}

/// Riverpod provider delivering GoRouter configuration with auth guard redirect
/// and [AppDesktopShell] integration.
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: AppRoutes.auth,
    redirect: (context, state) {
      final isAuthRoute = state.matchedLocation == AppRoutes.auth;
      if (authState.status == AuthStatus.initial || authState.status == AuthStatus.loading) return null;

      if (authState.status == AuthStatus.unauthenticated || authState.status == AuthStatus.error) {
        return isAuthRoute ? null : AppRoutes.auth;
      }

      if (authState.status == AuthStatus.authenticated && isAuthRoute) {
        return AppRoutes.dashboard;
      }

      return null;
    },
    routes: [
      // Authentication screen (unwrapped full screen)
      GoRoute(path: AppRoutes.auth, builder: (_, __) => const AuthScreen()),

      // Main application screens wrapped in AppDesktopShell
      ShellRoute(
        builder: (context, state, child) {
          return AppDesktopShell(
            currentPath: state.matchedLocation,
            child: child,
          );
        },
        routes: [
          GoRoute(path: AppRoutes.dashboard, builder: (_, __) => const DashboardScreen()),
          GoRoute(path: AppRoutes.profile, builder: (_, __) => const ProfileScreen()),
          GoRoute(path: AppRoutes.employees, builder: (_, __) => const EmployeesScreen()),
          GoRoute(path: AppRoutes.employeeCreate, builder: (_, __) => const EmployeeFormScreen()),
          GoRoute(
            path: '${AppRoutes.employees}/:id',
            builder: (_, state) => EmployeeDetailScreen(employeeId: int.parse(state.pathParameters['id']!)),
          ),
          GoRoute(
            path: '${AppRoutes.employees}/:id/edit',
            builder: (_, state) => EmployeeFormScreen(employeeId: int.parse(state.pathParameters['id']!)),
          ),
          GoRoute(path: AppRoutes.leave, builder: (_, __) => const LeaveScreen()),
          GoRoute(path: AppRoutes.leaveApply, builder: (_, __) => const LeaveFormScreen()),
          GoRoute(
            path: '${AppRoutes.leave}/:id',
            builder: (_, state) => LeaveDetailScreen(leaveRequestId: int.parse(state.pathParameters['id']!)),
          ),
          GoRoute(path: AppRoutes.departments, builder: (_, __) => const DepartmentsScreen()),
          GoRoute(path: AppRoutes.departmentCreate, builder: (_, __) => const DepartmentFormScreen()),
          GoRoute(
            path: '${AppRoutes.departments}/:id',
            builder: (_, state) => DepartmentDetailScreen(departmentId: int.parse(state.pathParameters['id']!)),
          ),
          GoRoute(
            path: '${AppRoutes.departments}/:id/edit',
            builder: (_, state) => DepartmentFormScreen(departmentId: int.parse(state.pathParameters['id']!)),
          ),
          GoRoute(path: AppRoutes.policies, builder: (_, __) => const PoliciesScreen()),
          GoRoute(path: AppRoutes.policyCreate, builder: (_, __) => const PolicyFormScreen()),
          GoRoute(
            path: '${AppRoutes.policies}/:id',
            builder: (_, state) => PolicyDetailScreen(policyId: int.parse(state.pathParameters['id']!)),
          ),
          GoRoute(
            path: '${AppRoutes.policies}/:id/edit',
            builder: (_, state) => PolicyFormScreen(policyId: int.parse(state.pathParameters['id']!)),
          ),
          GoRoute(path: AppRoutes.chat, builder: (_, __) => const ChatScreen()),
        ],
      ),
    ],
  );
});
