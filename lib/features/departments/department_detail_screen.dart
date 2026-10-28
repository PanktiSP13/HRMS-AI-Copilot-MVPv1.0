import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../common/constants/app_constants.dart';
import '../../common/formatters.dart';
import '../../common/widgets/app_toast.dart';
import '../../common/widgets/app_ui.dart';
import '../../common/widgets/responsive_layout.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/department_provider.dart';
import '../../core/router/app_router.dart';

class DepartmentDetailScreen extends ConsumerStatefulWidget {
  final int departmentId;
  const DepartmentDetailScreen({super.key, required this.departmentId});

  @override
  ConsumerState<DepartmentDetailScreen> createState() => _DepartmentDetailScreenState();
}

class _DepartmentDetailScreenState extends ConsumerState<DepartmentDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(departmentProvider.notifier).loadDepartment(widget.departmentId));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(departmentProvider);
    final department = state.selectedDepartment;
    final isAdmin = ref.watch(authProvider).user?.role == UserRole.hrAdmin;
    final isDesktop = AppBreakpoints.isDesktop(context);

    return Scaffold(
      backgroundColor: const Color(AppColors.background),
      appBar: AppBar(title: const Text(AppStrings.details), leading: const AppBackButton()),
      body: state.isLoading && department == null
          ? const Center(child: CircularProgressIndicator())
          : department == null
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
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              const CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Color(AppColors.softBlue),
                                  child: Icon(Icons.apartment_outlined, color: Color(AppColors.info), size: 30)),
                              const SizedBox(height: 12),
                              Text(department.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                              const SizedBox(height: 4),
                              Text(department.code, style: const TextStyle(color: Color(AppColors.mutedText))),
                              const SizedBox(height: 10),
                              AppStatusChip(status: department.isActive ? AppStrings.active : AppStrings.inactive),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                          child: Column(
                            children: [
                              AppInfoRow(icon: Icons.label_outline, label: AppStrings.code, value: department.code),
                              AppInfoRow(icon: Icons.notes_outlined, label: AppStrings.description, value: department.description ?? ''),
                              AppInfoRow(
                                  icon: Icons.calendar_today_outlined, label: AppStrings.createdAt, value: AppFormatters.date(department.createdAt)),
                            ],
                          ),
                        ),
                      ),
                      if (isAdmin) ...[
                        const SizedBox(height: 18),
                        FilledButton.icon(
                          onPressed: () async {
                            final changed = await context.push<bool>(AppRoutes.departmentEdit(department.id));
                            if (changed == true) {
                              if (!context.mounted) return;
                              await ref.read(departmentProvider.notifier).loadDepartment(department.id);
                              await ref.read(departmentProvider.notifier).loadDepartments();
                              if (context.mounted) AppToast.success(context, AppStrings.departmentUpdated);
                            }
                          },
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text(AppStrings.edit),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: () => _delete(department.id),
                          icon: const Icon(Icons.delete_outline),
                          label: const Text(AppStrings.delete),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }

  Future<void> _delete(int id) async {
    final confirmed = await AppDialogs.confirm(
      context,
      title: AppStrings.delete,
      message: AppStrings.confirmDelete,
    );
    if (!confirmed || !mounted) return;

    await ref.read(departmentProvider.notifier).deleteDepartment(id);
    if (!mounted) return;
    final error = ref.read(departmentProvider).errorMessage;
    if (error != null) {
      AppToast.error(context, error);
      return;
    }
    AppToast.success(context, AppStrings.departmentDeleted);
    context.pop(true);
  }
}
