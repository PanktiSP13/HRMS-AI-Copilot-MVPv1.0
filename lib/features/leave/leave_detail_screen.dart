import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hrms_ai_copilot/core/network/api_config.dart';

import '../../common/constants/app_constants.dart';
import '../../common/formatters.dart';
import '../../common/widgets/app_toast.dart';
import '../../common/widgets/app_ui.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/employee_provider.dart';
import '../../core/providers/leave_provider.dart';
import '../../models/employee.dart';
import '../../models/leave_request.dart';

class LeaveDetailScreen extends ConsumerStatefulWidget {
  final int leaveRequestId;
  const LeaveDetailScreen({super.key, required this.leaveRequestId});

  @override
  ConsumerState<LeaveDetailScreen> createState() => _LeaveDetailScreenState();
}

class _LeaveDetailScreenState extends ConsumerState<LeaveDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(leaveProvider.notifier).loadLeaveRequest(widget.leaveRequestId);
      final role = ref.read(authProvider).user?.role;
      if (role == UserRole.manager || role == UserRole.hrAdmin) {
        await ref.read(employeeProvider.notifier).loadEmployees();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(leaveProvider);
    final request = state.selectedLeaveRequest;
    final role = ref.watch(authProvider).user?.role;
    final canApprove = role == UserRole.manager || role == UserRole.hrAdmin;
    final employees = ref.watch(employeeProvider).employees;

    Employee? employee;
    final matches = request == null ? <Employee>[] : employees.where((item) => item.id == request.employeeId).toList();
    if (matches.isNotEmpty) employee = matches.first;

    return Scaffold(
      backgroundColor: const Color(AppColors.background),
      appBar: AppBar(title: const Text(AppStrings.leaveDetails), leading: const AppBackButton()),
      body: state.isLoading && request == null
          ? const Center(child: CircularProgressIndicator())
          : request == null
              ? Center(child: Text(state.errorMessage ?? AppStrings.noData))
              : ListView(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          children: [
                            employee == null
                                ? const CircleAvatar(
                                    radius: 26,
                                    backgroundColor: Color(AppColors.primaryLight),
                                    child: Icon(Icons.event_note_outlined, color: Color(AppColors.primary)),
                                  )
                                : AppAvatar(
                                    name: employee.name,
                                    imageUrl: employee.profileImageUrl == null ? null : '${AppConfig.apiBaseUrl}${employee.profileImageUrl}',
                                    radius: 26,
                                  ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(request.leaveType, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                                  const SizedBox(height: 4),
                                  Text(employee == null ? 'Employee #${request.employeeId}' : '${employee.name} (#${request.employeeId})',
                                      style: const TextStyle(color: Color(AppColors.mutedText))),
                                ],
                              ),
                            ),
                            AppStatusChip(status: request.status),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: Column(
                          children: [
                            AppInfoRow(
                                icon: Icons.calendar_today_outlined, label: AppStrings.startDate, value: AppFormatters.date(request.startDate)),
                            AppInfoRow(icon: Icons.event_outlined, label: AppStrings.endDate, value: AppFormatters.date(request.endDate)),
                            AppInfoRow(icon: Icons.notes_outlined, label: AppStrings.reason, value: request.reason ?? ''),
                            AppInfoRow(icon: Icons.comment_outlined, label: AppStrings.comment, value: request.comment ?? ''),
                            if (request.rejectionReason != null)
                              AppInfoRow(icon: Icons.info_outline, label: AppStrings.rejectionReason, value: request.rejectionReason!),
                          ],
                        ),
                      ),
                    ),
                    if (canApprove && request.status == LeaveStatus.pending) ...[
                      const SizedBox(height: 18),
                      FilledButton.icon(
                        onPressed: state.isLoading ? null : () => _updateStatus(LeaveStatus.approved),
                        icon: const Icon(Icons.check),
                        label: const Text(AppStrings.approve),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: state.isLoading ? null : () => _updateStatus(LeaveStatus.rejected),
                        icon: const Icon(Icons.close),
                        label: const Text(AppStrings.reject),
                      ),
                    ],
                  ],
                ),
    );
  }

  Future<void> _updateStatus(String status) async {
    String? rejectionReason;
    if (status == LeaveStatus.rejected) {
      rejectionReason = await AppDialogs.textInput(
        context,
        title: AppStrings.reject,
        label: AppStrings.rejectionReason,
        confirmLabel: AppStrings.reject,
        requiredValue: true,
      );
      if (rejectionReason == null || rejectionReason.trim().isEmpty) {
        return;
      }
    }

    await ref.read(leaveProvider.notifier).updateLeaveRequestStatus(
          widget.leaveRequestId,
          LeaveRequestStatusUpdate(status: status, rejectionReason: rejectionReason),
        );

    if (!mounted) return;
    final error = ref.read(leaveProvider).errorMessage;
    if (error != null) {
      AppToast.error(context, error);
      return;
    }

    AppToast.success(
      context,
      status == LeaveStatus.approved ? AppStrings.leaveApproved : AppStrings.leaveRejected,
    );
    context.pop(true);
  }
}
