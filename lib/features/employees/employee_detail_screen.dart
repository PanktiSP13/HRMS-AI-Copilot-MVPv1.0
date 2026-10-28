import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hrms_ai_copilot/core/network/api_config.dart';

import '../../common/constants/app_constants.dart';
import '../../common/formatters.dart';
import '../../common/widgets/app_toast.dart';
import '../../common/widgets/app_ui.dart';
import '../../common/widgets/responsive_layout.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/employee_provider.dart';
import '../../core/router/app_router.dart';

class EmployeeDetailScreen extends ConsumerStatefulWidget {
  final int employeeId;
  const EmployeeDetailScreen({super.key, required this.employeeId});

  @override
  ConsumerState<EmployeeDetailScreen> createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends ConsumerState<EmployeeDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final notifier = ref.read(employeeProvider.notifier);
      await notifier.loadEmployee(widget.employeeId);
      if (ref.read(authProvider).user?.role == UserRole.hrAdmin) {
        await notifier.loadEmployeeLeaveBalance(widget.employeeId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(employeeProvider);
    final employee = state.selectedEmployee;
    final isAdmin = ref.watch(authProvider).user?.role == UserRole.hrAdmin;
    final isDesktop = AppBreakpoints.isDesktop(context);

    return Scaffold(
      backgroundColor: const Color(AppColors.background),
      appBar: AppBar(title: const Text(AppStrings.details), automaticallyImplyLeading: !isDesktop),
      body: state.isLoading && employee == null
          ? const Center(child: CircularProgressIndicator())
          : employee == null
              ? Center(child: Text(state.errorMessage ?? AppStrings.noData))
              : ResponsiveCenter(
                  maxWidth: 800,
                  padding: EdgeInsets.fromLTRB(
                    isDesktop ? 28 : 18,
                    isDesktop ? 20 : 8,
                    isDesktop ? 28 : 18,
                    30,
                  ),
                  child: ListView(
                    children: [
                      Center(
                        child: AppAvatar(
                          name: employee.name,
                          imageUrl: employee.profileImageUrl == null ? null : '${AppConfig.apiBaseUrl}${employee.profileImageUrl}',
                          radius: 48,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(employee.name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text(employee.role, textAlign: TextAlign.center, style: const TextStyle(color: Color(AppColors.mutedText))),
                      const SizedBox(height: 8),
                      Center(child: AppStatusChip(status: employee.isActive ? AppStrings.active : AppStrings.inactive)),
                      const SizedBox(height: 20),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                          child: Column(
                            children: [
                              AppInfoRow(icon: Icons.badge_outlined, label: AppStrings.employeeCode, value: employee.employeeCode),
                              AppInfoRow(icon: Icons.mail_outline, label: AppStrings.email, value: employee.email),
                              AppInfoRow(icon: Icons.phone_outlined, label: AppStrings.phone, value: employee.phone ?? ''),
                              AppInfoRow(icon: Icons.apartment_outlined, label: AppStrings.department, value: employee.department ?? ''),
                              AppInfoRow(icon: Icons.person_outline, label: AppStrings.managerName, value: employee.managerName ?? ''),
                              AppInfoRow(icon: Icons.location_on_outlined, label: AppStrings.address, value: employee.address ?? ''),
                              AppInfoRow(
                                  icon: Icons.calendar_today_outlined, label: AppStrings.createdAt, value: AppFormatters.date(employee.createdAt)),
                            ],
                          ),
                        ),
                      ),
                      if (isAdmin && state.selectedEmployeeLeaveBalance != null) ...[
                        const SizedBox(height: 18),
                        const AppSectionTitle(title: AppStrings.leaveBalances),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                _balanceRow(AppStrings.annual, state.selectedEmployeeLeaveBalance!.annualLeave,
                                    state.selectedEmployeeLeaveBalance!.annualUsed),
                                _balanceRow(AppStrings.medical, state.selectedEmployeeLeaveBalance!.medicalLeave,
                                    state.selectedEmployeeLeaveBalance!.medicalUsed),
                                _balanceRow(AppStrings.casual, state.selectedEmployeeLeaveBalance!.casualLeave,
                                    state.selectedEmployeeLeaveBalance!.casualUsed),
                              ],
                            ),
                          ),
                        ),
                      ],
                      if (isAdmin) ...[
                        const SizedBox(height: 18),
                        FilledButton.icon(
                          onPressed: () async {
                            final changed = await context.push<bool>(AppRoutes.employeeEdit(employee.id));
                            if (changed == true) {
                              if (!context.mounted) return;
                              await ref.read(employeeProvider.notifier).loadEmployee(employee.id);
                              await ref.read(employeeProvider.notifier).loadEmployees();
                              if (context.mounted) AppToast.success(context, AppStrings.employeeUpdated);
                            }
                          },
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text(AppStrings.edit),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: employee.isActive ? () => _confirmDelete(employee.id) : null,
                          icon: const Icon(Icons.person_off_outlined),
                          label: const Text(AppStrings.deactivate),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _balanceRow(String type, double total, double used) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(child: Text(type, style: const TextStyle(fontWeight: FontWeight.w600))),
          Text('${total - used} left', style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(width: 10),
          Text('$used used', style: const TextStyle(color: Color(AppColors.mutedText), fontSize: 12)),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(int id) async {
    final confirmed = await AppDialogs.confirm(
      context,
      title: AppStrings.deactivate,
      message: AppStrings.confirmDeactivate,
      confirmLabel: AppStrings.deactivate,
    );
    if (!confirmed || !mounted) return;

    await ref.read(employeeProvider.notifier).deleteEmployee(id);
    if (!mounted) return;
    final error = ref.read(employeeProvider).errorMessage;
    if (error != null) {
      AppToast.error(context, error);
      return;
    }
    AppToast.success(context, AppStrings.employeeDeactivated);
    context.pop(true);
  }
}
