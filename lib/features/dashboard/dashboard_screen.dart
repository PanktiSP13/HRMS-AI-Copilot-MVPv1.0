import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../common/constants/app_constants.dart';
import '../../common/widgets/app_ui.dart';
import '../../common/widgets/responsive_layout.dart';
import '../../core/network/api_config.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/department_provider.dart';
import '../../core/providers/employee_provider.dart';
import '../../core/providers/leave_provider.dart';
import '../../core/providers/policy_provider.dart';
import '../../core/providers/profile_provider.dart';
import '../../core/router/app_router.dart';

/// [DashboardScreen] is the main home screen of the HRMS application.
///
/// It displays role-specific dashboard metrics, quick navigation cards,
/// and AI Copilot shortcuts tailored for Employees, Managers, and HR Admins.
/// Adaptive layout rules apply on desktop (grid cards) vs mobile (list cards).
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _bottomIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadDashboardData);
  }

  /// Loads profile and role-relevant dashboard data asynchronously.
  Future<void> _loadDashboardData() async {
    final role = ref.read(authProvider).user?.role;
    await ref.read(profileProvider.notifier).loadProfile();
    if (role == UserRole.employee) {
      await Future.wait([
        ref.read(profileProvider.notifier).loadLeaveBalances(),
        ref.read(profileProvider.notifier).loadLeaveRequests(),
      ]);
    } else if (role == UserRole.manager) {
      await Future.wait([
        ref.read(employeeProvider.notifier).loadEmployees(),
        ref.read(leaveProvider.notifier).loadLeaveRequests(),
        ref.read(policyProvider.notifier).loadPolicies(),
      ]);
    } else if (role == UserRole.hrAdmin) {
      await Future.wait([
        ref.read(employeeProvider.notifier).loadEmployees(),
        ref.read(departmentProvider.notifier).loadDepartments(),
        ref.read(policyProvider.notifier).loadPolicies(),
        ref.read(leaveProvider.notifier).loadLeaveRequests(),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final role = user?.role ?? UserRole.employee;
    final profile = ref.watch(profileProvider).profile;
    final imageUrl = profile?.profileImageUrl == null ? null : '${AppConfig.apiBaseUrl}${profile!.profileImageUrl}';
    final isDesktop = AppBreakpoints.isDesktop(context);

    if (_bottomIndex == 1 && !isDesktop) {
      return const _ProfileRedirectView();
    }

    return Scaffold(
      backgroundColor: const Color(AppColors.background),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDashboardData,
          child: ResponsiveCenter(
            maxWidth: 1200,
            padding: EdgeInsets.fromLTRB(
              isDesktop ? 28 : 18,
              isDesktop ? 24 : 10,
              isDesktop ? 28 : 18,
              24,
            ),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                _topGreeting(user?.name ?? AppStrings.notAvailable, imageUrl, role, isDesktop),
                const SizedBox(height: 16),
                AppHeaderCard(
                  name: profile?.name ?? user?.name ?? AppStrings.notAvailable,
                  role: profile?.role ?? role,
                  imageUrl: imageUrl,
                  department: profile?.department ?? user?.department,
                  onTap: () => context.go(AppRoutes.profile),
                ),
                const SizedBox(height: 22),
                _buildStats(role, isDesktop),
                const SizedBox(height: 22),
                AppSectionTitle(title: _sectionTitle(role)),
                const SizedBox(height: 12),
                _buildActionGrid(role, isDesktop),
                const SizedBox(height: 22),
                _buildCopilotCard(context, isDesktop),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: isDesktop
          ? null
          : NavigationBar(
              selectedIndex: _bottomIndex,
              onDestinationSelected: (index) {
                if (index == 1) {
                  context.go(AppRoutes.profile);
                } else {
                  setState(() => _bottomIndex = 0);
                }
              },
              destinations: const [
                NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: AppStrings.dashboard),
                NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: AppStrings.profile),
              ],
            ),
    );
  }

  /// Builds top greeting banner with user name, role label, and avatar.
  Widget _topGreeting(String name, String? imageUrl, String role, bool isDesktop) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, $name 👋',
                style: TextStyle(
                  fontSize: isDesktop ? 28 : 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Welcome to HRMS Dashboard • $role',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(AppColors.mutedText),
                ),
              ),
            ],
          ),
        ),
        if (!isDesktop)
          GestureDetector(
            onTap: () => context.go(AppRoutes.profile),
            child: AppAvatar(
              name: name,
              imageUrl: imageUrl,
              radius: 20,
            ),
          ),
      ],
    );
  }

  /// Builds statistics summary metrics cards for the current user's role.
  Widget _buildStats(String role, bool isDesktop) {
    if (role == UserRole.employee) {
      final state = ref.watch(profileProvider);
      final balance = state.leaveBalances.isEmpty ? null : state.leaveBalances.first;
      final pending = state.leaveRequests.where((e) => e.status == LeaveStatus.pending).length;
      return Row(
        children: [
          AppStatCard(
            label: AppStrings.leaveBalance,
            value: balance == null ? '—' : '${balance.annualLeave + balance.medicalLeave + balance.casualLeave}',
            icon: Icons.event_available_outlined,
            background: const Color(AppColors.lavender),
          ),
          const SizedBox(width: 14),
          AppStatCard(
            label: AppStrings.pendingRequests,
            value: '$pending',
            icon: Icons.pending_actions_outlined,
            background: const Color(AppColors.softOrange),
          ),
        ],
      );
    }

    if (role == UserRole.manager) {
      final employees = ref.watch(employeeProvider).employees;
      final pending = ref.watch(leaveProvider).leaveRequests.where((e) => e.status == LeaveStatus.pending).length;
      return Row(
        children: [
          AppStatCard(
            label: AppStrings.teamMembers,
            value: '${employees.length}',
            icon: Icons.groups_outlined,
            background: const Color(AppColors.lavender),
          ),
          const SizedBox(width: 14),
          AppStatCard(
            label: AppStrings.pendingRequests,
            value: '$pending',
            icon: Icons.pending_actions_outlined,
            background: const Color(AppColors.softOrange),
          ),
        ],
      );
    }

    final employees = ref.watch(employeeProvider).employees;
    final departments = ref.watch(departmentProvider).departments;
    final policies = ref.watch(policyProvider).policies;
    return Row(
      children: [
        AppStatCard(
          label: AppStrings.totalEmployees,
          value: '${employees.length}',
          icon: Icons.groups_outlined,
          background: const Color(AppColors.lavender),
        ),
        const SizedBox(width: 12),
        AppStatCard(
          label: AppStrings.totalDepartments,
          value: '${departments.length}',
          icon: Icons.apartment_outlined,
          background: const Color(AppColors.softBlue),
        ),
        const SizedBox(width: 12),
        AppStatCard(
          label: AppStrings.totalPolicies,
          value: '${policies.length}',
          icon: Icons.description_outlined,
          background: const Color(AppColors.softGreen),
        ),
      ],
    );
  }

  /// Returns localized section title string for the given role.
  String _sectionTitle(String role) {
    if (role == UserRole.manager) return AppStrings.teamActivity;
    if (role == UserRole.hrAdmin) return AppStrings.quickActions;
    return AppStrings.recentActivity;
  }

  /// Renders quick action cards in a responsive grid on desktop or column on mobile.
  Widget _buildActionGrid(String role, bool isDesktop) {
    final actions = _actionsForRole(role);
    if (!isDesktop) {
      return Column(
        children: actions
            .map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: a,
                ))
            .toList(),
      );
    }

    return ResponsiveGrid(
      mobileCrossAxisCount: 1,
      tabletCrossAxisCount: 2,
      desktopCrossAxisCount: 2,
      spacing: 14,
      runSpacing: 14,
      children: actions,
    );
  }

  /// Generates quick action card widgets suited for the specified user role.
  List<Widget> _actionsForRole(String role) {
    if (role == UserRole.employee) {
      return [
        AppActionCard(
          title: AppStrings.leave,
          subtitle: AppStrings.applyForLeave,
          icon: Icons.event_note_outlined,
          onTap: () => context.go(AppRoutes.leave),
        ),
        AppActionCard(
          title: AppStrings.policies,
          subtitle: 'View company policies',
          icon: Icons.policy_outlined,
          onTap: () => context.go(AppRoutes.policies),
        ),
        AppActionCard(
          title: AppStrings.aiCopilot,
          subtitle: 'Ask HR anything',
          icon: Icons.auto_awesome_outlined,
          onTap: () => context.go(AppRoutes.chat),
        ),
      ];
    }

    if (role == UserRole.manager) {
      return [
        AppActionCard(
          title: AppStrings.team,
          subtitle: 'View your direct reports',
          icon: Icons.groups_outlined,
          onTap: () => context.go(AppRoutes.employees),
        ),
        AppActionCard(
          title: AppStrings.leave,
          subtitle: 'Review team leave requests',
          icon: Icons.event_note_outlined,
          onTap: () => context.go(AppRoutes.leave),
        ),
        AppActionCard(
          title: AppStrings.policies,
          subtitle: 'View company policies',
          icon: Icons.policy_outlined,
          onTap: () => context.go(AppRoutes.policies),
        ),
        AppActionCard(
          title: AppStrings.aiCopilot,
          subtitle: 'Ask HR anything',
          icon: Icons.auto_awesome_outlined,
          onTap: () => context.go(AppRoutes.chat),
        ),
      ];
    }

    return [
      AppActionCard(
        title: AppStrings.employees,
        subtitle: 'Manage employees & team',
        icon: Icons.groups_outlined,
        onTap: () => context.go(AppRoutes.employees),
      ),
      AppActionCard(
        title: AppStrings.departments,
        subtitle: 'Manage organization structure',
        icon: Icons.apartment_outlined,
        onTap: () => context.go(AppRoutes.departments),
      ),
      AppActionCard(
        title: AppStrings.policies,
        subtitle: 'Manage company policies & PDFs',
        icon: Icons.policy_outlined,
        onTap: () => context.go(AppRoutes.policies),
      ),
      AppActionCard(
        title: AppStrings.leave,
        subtitle: 'Review & approve leave requests',
        icon: Icons.event_note_outlined,
        onTap: () => context.go(AppRoutes.leave),
      ),
    ];
  }

  /// Builds prominent AI Copilot banner card navigating to the AI assistant workspace.
  Widget _buildCopilotCard(BuildContext context, bool isDesktop) {
    return InkWell(
      onTap: () => context.go(AppRoutes.chat),
      borderRadius: BorderRadius.circular(AppDimens.cardRadius),
      child: Container(
        padding: EdgeInsets.all(isDesktop ? 22 : 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(AppColors.primary), Color(AppColors.primaryDark)],
          ),
          borderRadius: BorderRadius.circular(AppDimens.cardRadius),
          boxShadow: [
            BoxShadow(
              color: const Color(AppColors.primary).withAlpha(50),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    AppStrings.aiCopilot,
                    style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Get instant answers about HR processes, leave balances, employees, and policies.',
                    style: TextStyle(color: Colors.white.withAlpha(220), fontSize: isDesktop ? 13 : 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Open Chat',
                    style: TextStyle(
                      color: Color(AppColors.primary),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward_ios, color: Color(AppColors.primary), size: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileRedirectView extends StatelessWidget {
  const _ProfileRedirectView();

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
