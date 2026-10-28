import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../common/constants/app_constants.dart';
import '../../common/widgets/app_toast.dart';
import '../../common/widgets/app_ui.dart';
import '../../common/widgets/responsive_layout.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/department_provider.dart';
import '../../core/router/app_router.dart';
import '../../models/department.dart';

/// [DepartmentsScreen] displays company departments and organizational structure.
///
/// Features:
/// - Real-time department search by department name or code.
/// - Department creation and management for HR Admins.
/// - Adaptive layout: multi-column responsive grid on desktop (>= 900px), card list on mobile.
class DepartmentsScreen extends ConsumerStatefulWidget {
  const DepartmentsScreen({super.key});

  @override
  ConsumerState<DepartmentsScreen> createState() => _DepartmentsScreenState();
}

class _DepartmentsScreenState extends ConsumerState<DepartmentsScreen> {
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(departmentProvider.notifier).loadDepartments());
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(departmentProvider);
    final isAdmin = ref.watch(authProvider).user?.role == UserRole.hrAdmin;
    final isDesktop = AppBreakpoints.isDesktop(context);
    final query = _search.text.toLowerCase().trim();
    final departments =
        state.departments.where((d) => query.isEmpty || d.name.toLowerCase().contains(query) || d.code.toLowerCase().contains(query)).toList();

    return Scaffold(
      backgroundColor: const Color(AppColors.background),
      appBar: AppBar(
        title: const Text(AppStrings.departments),
        leading: const AppBackButton(),
        actions: [
          if (isDesktop && isAdmin)
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: FilledButton.icon(
                onPressed: () => _openAddDepartment(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text(AppStrings.addDepartment),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(departmentProvider.notifier).loadDepartments(),
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
                  const Expanded(
                    child: Text('Browse departments and organization structure.', style: TextStyle(color: Color(AppColors.mutedText))),
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
              if (state.isLoading && state.departments.isEmpty)
                const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
              else if (state.errorMessage != null && departments.isEmpty)
                Center(child: Padding(padding: const EdgeInsets.all(40), child: Text(state.errorMessage!)))
              else if (departments.isEmpty)
                const Center(child: Padding(padding: EdgeInsets.all(40), child: Text(AppStrings.noData)))
              else if (isDesktop)
                ResponsiveGrid(
                  mobileCrossAxisCount: 1,
                  tabletCrossAxisCount: 2,
                  desktopCrossAxisCount: 3,
                  spacing: 14,
                  runSpacing: 14,
                  children: departments.map((d) => _buildDepartmentCard(d)).toList(),
                )
              else
                ...departments.map((d) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildDepartmentCard(d),
                    )),
            ],
          ),
        ),
      ),
      floatingActionButton: (isAdmin && !isDesktop)
          ? FloatingActionButton.extended(
              onPressed: () => _openAddDepartment(context),
              backgroundColor: const Color(AppColors.primary),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text(AppStrings.addDepartment),
            )
          : null,
    );
  }

  /// Builds department summary card widget.
  Widget _buildDepartmentCard(Department department) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: const CircleAvatar(
          backgroundColor: Color(AppColors.softBlue),
          child: Icon(Icons.apartment_outlined, color: Color(AppColors.info)),
        ),
        title: Text(department.name, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(
          '${department.code} • ${department.description?.trim().isNotEmpty == true ? department.description! : AppStrings.notAvailable}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: AppStatusChip(status: department.isActive ? AppStrings.active : AppStrings.inactive),
        onTap: () async {
          final changed = await context.push<bool>(AppRoutes.departmentDetails(department.id));
          if (changed == true) {
            if (!context.mounted) return;
            await ref.read(departmentProvider.notifier).loadDepartments();
          }
        },
      ),
    );
  }

  /// Navigates to department creation form screen.
  Future<void> _openAddDepartment(BuildContext context) async {
    final created = await context.push<bool>(AppRoutes.departmentCreate);
    if (created == true) {
      if (!context.mounted) return;
      await ref.read(departmentProvider.notifier).loadDepartments();
      if (context.mounted) AppToast.success(context, AppStrings.departmentCreated);
    }
  }
}
