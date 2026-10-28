import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../common/constants/app_constants.dart';
import '../../common/formatters.dart';
import '../../common/widgets/app_toast.dart';
import '../../common/widgets/app_ui.dart';
import '../../common/widgets/responsive_layout.dart';
import '../../core/network/api_config.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/employee_provider.dart';
import '../../core/providers/leave_provider.dart';
import '../../core/providers/profile_provider.dart';
import '../../core/router/app_router.dart';
import '../../models/employee.dart';

/// [LeaveScreen] manages leave balance tracking and leave requests.
///
/// Features:
/// - "My Requests" tab for employees to apply, track, and cancel leave requests.
/// - "Team Leave" tab for Managers & HR Admins to approve/reject team leave.
/// - Summary balance banner displaying available annual, medical, and casual leave.
class LeaveScreen extends ConsumerStatefulWidget {
  const LeaveScreen({super.key});

  @override
  ConsumerState<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends ConsumerState<LeaveScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    final role = ref.read(authProvider).user?.role;
    final management = role == UserRole.manager || role == UserRole.hrAdmin;
    _tabs = TabController(length: management ? 2 : 1, vsync: this);
    Future.microtask(_loadData);
  }

  /// Async helper fetching leave balances and request lists.
  Future<void> _loadData() async {
    final role = ref.read(authProvider).user?.role;
    final management = role == UserRole.manager || role == UserRole.hrAdmin;
    await Future.wait([
      ref.read(profileProvider.notifier).loadLeaveBalances(),
      ref.read(profileProvider.notifier).loadLeaveRequests(),
      if (management) ref.read(leaveProvider.notifier).loadLeaveRequests(),
      if (management) ref.read(employeeProvider.notifier).loadEmployees(),
    ]);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(authProvider).user?.role;
    final management = role == UserRole.manager || role == UserRole.hrAdmin;
    final isDesktop = AppBreakpoints.isDesktop(context);

    return Scaffold(
      backgroundColor: const Color(AppColors.background),
      appBar: AppBar(
        title: const Text(AppStrings.leave),
        leading: const AppBackButton(),
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          tabs: [
            const Tab(text: AppStrings.leaveRequests),
            if (management) const Tab(text: AppStrings.team),
          ],
        ),
        actions: [
          if (isDesktop)
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: FilledButton.icon(
                onPressed: () => _applyLeave(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text(AppStrings.applyLeave),
              ),
            ),
        ],
      ),
      floatingActionButton: !isDesktop
          ? FloatingActionButton.extended(
              onPressed: () => _applyLeave(context),
              backgroundColor: const Color(AppColors.primary),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text(AppStrings.applyLeave),
            )
          : null,
      body: ResponsiveCenter(
        maxWidth: 1200,
        child: Column(
          children: [
            const _LeaveSummaryCard(),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  const _MyRequestsView(),
                  if (management) const _ManagementRequestsView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Opens leave application form.
  Future<void> _applyLeave(BuildContext context) async {
    final created = await context.push<bool>(AppRoutes.leaveApply);
    if (created == true) {
      if (!context.mounted) return;
      await Future.wait([
        ref.read(profileProvider.notifier).loadLeaveBalances(),
        ref.read(profileProvider.notifier).loadLeaveRequests(),
      ]);
      if (context.mounted) AppToast.success(context, AppStrings.leaveSubmitted);
    }
  }
}

/// Header banner displaying remaining leave balance and pending requests count.
class _LeaveSummaryCard extends ConsumerWidget {
  const _LeaveSummaryCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileProvider);
    final balance = state.leaveBalances.isEmpty ? null : state.leaveBalances.first;
    final pending = state.leaveRequests.where((e) => e.status == LeaveStatus.pending).length;
    final isDesktop = AppBreakpoints.isDesktop(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        isDesktop ? 28 : 18,
        14,
        isDesktop ? 28 : 18,
        8,
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _summaryItem(
                  AppStrings.leaveBalance,
                  balance == null ? AppStrings.notAvailable : '${balance.annualLeave + balance.medicalLeave + balance.casualLeave}',
                  Icons.event_available_outlined,
                  const Color(AppColors.lavender),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _summaryItem(
                  AppStrings.pendingRequests,
                  '$pending',
                  Icons.pending_actions_outlined,
                  const Color(AppColors.softOrange),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryItem(String label, String value, IconData icon, Color background) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(AppDimens.smallRadius)),
      child: Row(
        children: [
          Icon(icon, color: const Color(AppColors.primary), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(label, style: const TextStyle(fontSize: 11, color: Color(AppColors.mutedText))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tab view displaying current logged-in employee's leave requests.
class _MyRequestsView extends ConsumerWidget {
  const _MyRequestsView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileProvider);
    final isDesktop = AppBreakpoints.isDesktop(context);
    if (state.isLoading && state.leaveRequests.isEmpty) return const Center(child: CircularProgressIndicator());
    if (state.leaveRequests.isEmpty) return const Center(child: Text(AppStrings.noData));

    return RefreshIndicator(
      onRefresh: () => ref.read(profileProvider.notifier).loadLeaveRequests(),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          isDesktop ? 28 : 18,
          10,
          isDesktop ? 28 : 18,
          100,
        ),
        itemCount: state.leaveRequests.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, index) {
          final request = state.leaveRequests[index];
          final canCancel = request.status == LeaveStatus.pending;
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: const CircleAvatar(
                backgroundColor: Color(AppColors.primaryLight),
                child: Icon(Icons.event_note_outlined, color: Color(AppColors.primary)),
              ),
              title: Text(request.leaveType, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(
                  '${AppFormatters.dateRange(request.startDate, request.endDate)}\n${request.reason?.trim().isNotEmpty == true ? request.reason! : AppStrings.notAvailable}'),
              isThreeLine: true,
              trailing: canCancel
                  ? IconButton(
                      onPressed: () async {
                        final confirmed = await AppDialogs.confirm(
                          context,
                          title: AppStrings.cancel,
                          message: AppStrings.leaveCancelConfirm,
                          confirmLabel: AppStrings.cancel,
                        );
                        if (!confirmed) return;
                        await ref.read(profileProvider.notifier).cancelLeaveRequest(request.id);
                        if (!context.mounted) return;
                        final error = ref.read(profileProvider).errorMessage;
                        if (error != null) {
                          AppToast.error(context, error);
                        } else {
                          AppToast.success(context, AppStrings.leaveCancelled);
                        }
                      },
                      icon: const Icon(Icons.close, color: Color(AppColors.danger)),
                    )
                  : AppStatusChip(status: request.status),
              onTap: () async {
                final changed = await context.push<bool>(AppRoutes.leaveDetails(request.id));
                if (changed == true) await ref.read(profileProvider.notifier).loadLeaveRequests();
              },
            ),
          );
        },
      ),
    );
  }
}

/// Tab view displaying team leave requests for Manager/HR approval workflow.
class _ManagementRequestsView extends ConsumerWidget {
  const _ManagementRequestsView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(leaveProvider);
    final employees = ref.watch(employeeProvider).employees;
    final isDesktop = AppBreakpoints.isDesktop(context);

    if (state.isLoading && state.leaveRequests.isEmpty) return const Center(child: CircularProgressIndicator());
    if (state.leaveRequests.isEmpty) return const Center(child: Text(AppStrings.noData));

    String employeeLabel(int id) {
      final matches = employees.where((employee) => employee.id == id);
      if (matches.isEmpty) return 'Employee #$id';
      return '${matches.first.name} (#$id)';
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          ref.read(leaveProvider.notifier).loadLeaveRequests(),
          ref.read(employeeProvider.notifier).loadEmployees(),
        ]);
      },
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          isDesktop ? 28 : 18,
          10,
          isDesktop ? 28 : 18,
          100,
        ),
        itemCount: state.leaveRequests.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, index) {
          final request = state.leaveRequests[index];
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: _employeeAvatar(employees, request.employeeId),
              title: Text(employeeLabel(request.employeeId), style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('${request.leaveType} • ${AppFormatters.dateRange(request.startDate, request.endDate)}'),
              trailing: AppStatusChip(status: request.status),
              onTap: () async {
                final changed = await context.push<bool>(AppRoutes.leaveDetails(request.id));
                if (changed == true) await ref.read(leaveProvider.notifier).loadLeaveRequests();
              },
            ),
          );
        },
      ),
    );
  }

  Widget _employeeAvatar(List<Employee> employees, int id) {
    final matches = employees.where((employee) => employee.id == id);
    if (matches.isEmpty) {
      return const CircleAvatar(
        backgroundColor: Color(AppColors.softOrange),
        child: Icon(Icons.person_outline, color: Color(AppColors.warning)),
      );
    }
    final employee = matches.first;
    return AppAvatar(
      name: employee.name,
      imageUrl: employee.profileImageUrl == null ? null : '${AppConfig.apiBaseUrl}${employee.profileImageUrl}',
      radius: 22,
    );
  }
}
