import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hrms_ai_copilot/core/network/api_config.dart';

import '../../common/constants/app_constants.dart';
import '../../common/widgets/app_toast.dart';
import '../../common/widgets/app_ui.dart';
import '../../common/widgets/responsive_layout.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/employee_provider.dart';
import '../../core/router/app_router.dart';
import '../../models/employee.dart';

/// [EmployeesScreen] manages organizational workforce and team directory.
///
/// Features:
/// - Real-time filtering by employee name, code, or email.
/// - Role-based permissions (HR Admin can create/deactivate employees; Manager views direct team).
/// - Adaptive layout: multi-column responsive grid on desktop (>= 900px), card list on mobile.
class EmployeesScreen extends ConsumerStatefulWidget {
  const EmployeesScreen({super.key});

  @override
  ConsumerState<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends ConsumerState<EmployeesScreen> {
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(employeeProvider.notifier).loadEmployees());
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(employeeProvider);
    final role = ref.watch(authProvider).user?.role;
    final isAdmin = role == UserRole.hrAdmin;
    final title = isAdmin ? AppStrings.employees : AppStrings.team;
    final isDesktop = AppBreakpoints.isDesktop(context);
    final query = _search.text.toLowerCase().trim();
    final employees = state.employees.where((e) {
      return query.isEmpty ||
          e.name.toLowerCase().contains(query) ||
          e.employeeCode.toLowerCase().contains(query) ||
          e.email.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(AppColors.background),
      appBar: AppBar(
        title: Text(title),
        leading: const AppBackButton(),
        actions: [
          if (isDesktop && isAdmin)
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: FilledButton.icon(
                onPressed: () => _openAddEmployee(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text(AppStrings.addEmployee),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(employeeProvider.notifier).loadEmployees(),
        child: ResponsiveCenter(
          maxWidth: 1200,
          padding: EdgeInsets.fromLTRB(
            isDesktop ? 28 : 18,
            isDesktop ? 20 : 8,
            isDesktop ? 28 : 18,
            100,
          ),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAdmin ? 'Manage people across your organization.' : 'Your direct reports and team members.',
                          style: const TextStyle(color: Color(AppColors.mutedText)),
                        ),
                      ],
                    ),
                  ),
                  if (isDesktop)
                    SizedBox(
                      width: 320,
                      child: TextField(
                        controller: _search,
                        textInputAction: TextInputAction.search,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          hintText: AppStrings.search,
                          prefixIcon: Icon(Icons.search),
                          isDense: true,
                        ),
                      ),
                    ),
                ],
              ),
              if (!isDesktop) ...[
                const SizedBox(height: 14),
                TextField(
                  controller: _search,
                  textInputAction: TextInputAction.search,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(hintText: AppStrings.search, prefixIcon: Icon(Icons.search)),
                ),
              ],
              const SizedBox(height: 20),
              if (state.isLoading && state.employees.isEmpty)
                const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()))
              else if (state.errorMessage != null && state.employees.isEmpty)
                _ErrorCard(message: state.errorMessage!, onRetry: () => ref.read(employeeProvider.notifier).loadEmployees())
              else if (employees.isEmpty)
                const Padding(padding: EdgeInsets.all(40), child: Center(child: Text(AppStrings.noData)))
              else if (isDesktop)
                ResponsiveGrid(
                  mobileCrossAxisCount: 1,
                  tabletCrossAxisCount: 2,
                  desktopCrossAxisCount: 3,
                  spacing: 14,
                  runSpacing: 14,
                  children: employees.map((e) => _buildEmployeeCard(e)).toList(),
                )
              else
                ...employees.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildEmployeeCard(e),
                    )),
            ],
          ),
        ),
      ),
      floatingActionButton: (isAdmin && !isDesktop)
          ? FloatingActionButton.extended(
              onPressed: () => _openAddEmployee(context),
              backgroundColor: const Color(AppColors.primary),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text(AppStrings.addEmployee),
            )
          : null,
    );
  }

  /// Builds employee overview card widget.
  Widget _buildEmployeeCard(Employee employee) {
    final imageUrl = employee.profileImageUrl == null ? null : '${AppConfig.apiBaseUrl}${employee.profileImageUrl}';
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
        onTap: () async {
          final changed = await context.push<bool>(AppRoutes.employeeDetails(employee.id));
          if (changed == true) {
            if (!context.mounted) return;
            await ref.read(employeeProvider.notifier).loadEmployees();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              AppAvatar(name: employee.name, imageUrl: imageUrl, radius: 26),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(employee.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(
                      '${employee.role} • ${employee.department ?? AppStrings.notAvailable}',
                      style: const TextStyle(fontSize: 12, color: Color(AppColors.mutedText)),
                    ),
                    const SizedBox(height: 4),
                    Text(employee.employeeCode, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              AppStatusChip(status: employee.isActive ? AppStrings.active : AppStrings.inactive),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right, color: Color(AppColors.mutedText)),
            ],
          ),
        ),
      ),
    );
  }

  /// Opens employee creation form screen.
  Future<void> _openAddEmployee(BuildContext context) async {
    final created = await context.push<bool>(AppRoutes.employeeCreate);
    if (created == true) {
      if (!context.mounted) return;
      await ref.read(employeeProvider.notifier).loadEmployees();
      if (context.mounted) AppToast.success(context, AppStrings.employeeCreated);
    }
  }
}

/// Fallback error indicator card widget with retry action.
class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 10),
              OutlinedButton(onPressed: onRetry, child: const Text(AppStrings.retry)),
            ],
          ),
        ),
      );
}
