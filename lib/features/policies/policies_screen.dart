import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hrms_ai_copilot/features/policies/policy_permissions.dart';

import '../../common/constants/app_constants.dart';
import '../../common/widgets/app_toast.dart';
import '../../common/widgets/app_ui.dart';
import '../../common/widgets/responsive_layout.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/policy_provider.dart';
import '../../core/router/app_router.dart';
import '../../models/policy.dart';

class PoliciesScreen extends ConsumerStatefulWidget {
  const PoliciesScreen({super.key});

  @override
  ConsumerState<PoliciesScreen> createState() => _PoliciesScreenState();
}

class _PoliciesScreenState extends ConsumerState<PoliciesScreen> {
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(policyProvider.notifier).loadPolicies());
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(policyProvider);
    final role = ref.watch(authProvider).user?.role;
    final canManagePolicies = PolicyPermissions.canEdit(role);
    final isDesktop = AppBreakpoints.isDesktop(context);
    final query = _search.text.toLowerCase().trim();
    final policies =
        state.policies.where((p) => query.isEmpty || p.name.toLowerCase().contains(query) || p.category.toLowerCase().contains(query)).toList();

    return Scaffold(
      backgroundColor: const Color(AppColors.background),
      appBar: AppBar(
        title: const Text(AppStrings.policies),
        leading: const AppBackButton(),
        actions: [
          if (isDesktop && canManagePolicies)
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: FilledButton.icon(
                onPressed: () => _openAddPolicy(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text(AppStrings.addPolicy),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(policyProvider.notifier).loadPolicies(),
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
                    child: Text('Company policies and guidelines in one place.', style: TextStyle(color: Color(AppColors.mutedText))),
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
              if (state.isLoading && state.policies.isEmpty)
                const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
              else if (state.errorMessage != null && policies.isEmpty)
                Center(child: Padding(padding: const EdgeInsets.all(40), child: Text(state.errorMessage!)))
              else if (policies.isEmpty)
                const Center(child: Padding(padding: EdgeInsets.all(40), child: Text(AppStrings.noData)))
              else if (isDesktop)
                ResponsiveGrid(
                  mobileCrossAxisCount: 1,
                  tabletCrossAxisCount: 2,
                  desktopCrossAxisCount: 3,
                  spacing: 14,
                  runSpacing: 14,
                  children: policies.map((p) => _buildPolicyCard(p)).toList(),
                )
              else
                ...policies.map((p) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildPolicyCard(p),
                    )),
            ],
          ),
        ),
      ),
      floatingActionButton: (canManagePolicies && !isDesktop)
          ? FloatingActionButton.extended(
              onPressed: () => _openAddPolicy(context),
              backgroundColor: const Color(AppColors.primary),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text(AppStrings.addPolicy),
            )
          : null,
    );
  }

  Widget _buildPolicyCard(Policy policy) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: const CircleAvatar(
          backgroundColor: Color(AppColors.softGreen),
          child: Icon(Icons.policy_outlined, color: Color(AppColors.success)),
        ),
        title: Text(policy.name, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text('${policy.category} • ${policy.version}'),
        trailing: AppStatusChip(status: policy.isActive ? AppStrings.active : AppStrings.inactive),
        onTap: () async {
          final changed = await context.push<bool>(AppRoutes.policyDetails(policy.id));
          if (changed == true) {
            if (!context.mounted) return;
            await ref.read(policyProvider.notifier).loadPolicies();
          }
        },
      ),
    );
  }

  Future<void> _openAddPolicy(BuildContext context) async {
    final created = await context.push<bool>(AppRoutes.policyCreate);
    if (created == true) {
      if (!context.mounted) return;
      await ref.read(policyProvider.notifier).loadPolicies();
      if (context.mounted) AppToast.success(context, AppStrings.policyCreated);
    }
  }
}
