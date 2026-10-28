import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../common/constants/app_constants.dart';
import '../../core/network/api_config.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/profile_provider.dart';
import '../../core/router/app_router.dart';
import 'app_ui.dart';
import 'responsive_layout.dart';

/// [AppDesktopShell] wraps the primary application screens inside a desktop sidebar shell
/// when running on wide viewports (width >= 900px).
///
/// It renders a persistent left sidebar containing:
/// - HRMS Copilot branding & logo header
/// - User profile badge & avatar summary
/// - Role-aware primary navigation links (Dashboard, Employees/Team, Departments, Leave, Policies, AI Copilot, Profile)
/// - Logout confirmation button
///
/// On mobile screen sizes (< 900px), it returns the [child] directly so mobile-native layouts apply.
class AppDesktopShell extends ConsumerWidget {
  /// The active route screen widget provided by GoRouter ShellRoute.
  final Widget child;

  /// The current URI route path (used to highlight active navigation items).
  final String currentPath;

  const AppDesktopShell({
    super.key,
    required this.child,
    required this.currentPath,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = AppBreakpoints.isDesktop(context);

    // Fall back to native child screen on mobile/portrait devices.
    if (!isDesktop) {
      return child;
    }

    final authState = ref.watch(authProvider);
    final user = authState.user;
    final role = user?.role ?? UserRole.employee;
    final profile = ref.watch(profileProvider).profile;
    final name = profile?.name ?? user?.name ?? AppStrings.appName;
    final rawImg = profile?.profileImageUrl;
    final imageUrl = rawImg == null ? null : '${AppConfig.apiBaseUrl}$rawImg';

    // Construct role-specific desktop navigation items.
    final navItems = <_NavItem>[
      const _NavItem(
        title: AppStrings.dashboard,
        route: AppRoutes.dashboard,
        icon: Icons.dashboard_outlined,
        selectedIcon: Icons.dashboard,
      ),
      if (role == UserRole.manager || role == UserRole.hrAdmin)
        _NavItem(
          title: role == UserRole.hrAdmin ? AppStrings.employees : AppStrings.team,
          route: AppRoutes.employees,
          icon: Icons.groups_outlined,
          selectedIcon: Icons.groups,
        ),
      if (role == UserRole.hrAdmin)
        const _NavItem(
          title: AppStrings.departments,
          route: AppRoutes.departments,
          icon: Icons.apartment_outlined,
          selectedIcon: Icons.apartment,
        ),
      const _NavItem(
        title: AppStrings.leave,
        route: AppRoutes.leave,
        icon: Icons.event_note_outlined,
        selectedIcon: Icons.event_note,
      ),
      const _NavItem(
        title: AppStrings.policies,
        route: AppRoutes.policies,
        icon: Icons.policy_outlined,
        selectedIcon: Icons.policy,
      ),
      const _NavItem(
        title: AppStrings.aiCopilot,
        route: AppRoutes.chat,
        icon: Icons.auto_awesome_outlined,
        selectedIcon: Icons.auto_awesome,
        isSpecial: true,
      ),
      const _NavItem(
        title: AppStrings.profile,
        route: AppRoutes.profile,
        icon: Icons.person_outline,
        selectedIcon: Icons.person,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(AppColors.background),
      body: Row(
        children: [
          // Sidebar Panel Container
          Container(
            width: 270,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                right: BorderSide(color: Color(AppColors.border), width: 1),
              ),
            ),
            child: Column(
              children: [
                // App Branding Header Widget
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(AppColors.primary),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: const Icon(Icons.work_outline, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.appName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(AppColors.primaryLight),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Desktop Pro',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(AppColors.primary),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                const SizedBox(height: 12),

                // User Profile Info Banner Widget
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => context.go(AppRoutes.profile),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(AppColors.background),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(AppColors.border)),
                      ),
                      child: Row(
                        children: [
                          AppAvatar(name: name, imageUrl: imageUrl, radius: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  role,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 11, color: Color(AppColors.mutedText)),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, size: 16, color: Color(AppColors.mutedText)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Navigation Items List View
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: navItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      final item = navItems[index];
                      final isSelected = _isRouteSelected(currentPath, item.route);

                      if (item.isSpecial) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: InkWell(
                            onTap: () => context.go(item.route),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(AppColors.primary), Color(AppColors.primaryDark)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: const Color(AppColors.primary).withAlpha(80),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        )
                                      ]
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white24,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'AI',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      return Material(
                        color: Colors.transparent,
                        child: ListTile(
                          dense: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          tileColor: isSelected ? const Color(AppColors.primaryLight) : Colors.transparent,
                          leading: Icon(
                            isSelected ? item.selectedIcon : item.icon,
                            color: isSelected ? const Color(AppColors.primary) : const Color(AppColors.mutedText),
                            size: 20,
                          ),
                          title: Text(
                            item.title,
                            style: TextStyle(
                              color: isSelected ? const Color(AppColors.primary) : const Color(AppColors.text),
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          onTap: () => context.go(item.route),
                        ),
                      );
                    },
                  ),
                ),

                const Divider(height: 1, indent: 16, endIndent: 16),

                // Sign Out Button Widget
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final confirmed = await AppDialogs.confirm(
                        context,
                        title: AppStrings.signOut,
                        message: AppStrings.signOutConfirm,
                        confirmLabel: AppStrings.signOut,
                      );
                      if (confirmed) {
                        ref.read(authProvider.notifier).logout();
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(AppColors.danger),
                      side: const BorderSide(color: Color(0xFFFFCDD2)),
                      minimumSize: const Size.fromHeight(42),
                    ),
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text(AppStrings.signOut),
                  ),
                ),
              ],
            ),
          ),

          // Main Screen Content Area View
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }

  /// Helper function to check if [target] route is selected under [current] path.
  bool _isRouteSelected(String current, String target) {
    if (current == target) return true;
    if (target != AppRoutes.dashboard && current.startsWith(target)) return true;
    return false;
  }
}

/// Data class holding sidebar navigation item specifications.
class _NavItem {
  final String title;
  final String route;
  final IconData icon;
  final IconData selectedIcon;
  final bool isSpecial;

  const _NavItem({
    required this.title,
    required this.route,
    required this.icon,
    required this.selectedIcon,
    this.isSpecial = false,
  });
}
