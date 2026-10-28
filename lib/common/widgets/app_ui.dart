import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../constants/app_constants.dart';
import '../formatters.dart';

/// Reusable Back Arrow Button handling smart pop or fallback navigation to Dashboard.
class AppBackButton extends StatelessWidget {
  final Color? color;
  final VoidCallback? onPressed;

  const AppBackButton({super.key, this.color, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back, color: color),
      tooltip: 'Back',
      onPressed: onPressed ??
          () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.dashboard);
            }
          },
    );
  }
}

class AppPage extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final List<Widget>? actions;
  final bool showBack;
  final int? bottomIndex;
  final ValueChanged<int>? onBottomNavigation;

  const AppPage({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.actions,
    this.showBack = true,
    this.bottomIndex,
    this.onBottomNavigation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: showBack,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            if (subtitle != null) Text(subtitle!, style: const TextStyle(fontSize: 12, color: Color(AppColors.mutedText))),
          ],
        ),
        actions: actions,
      ),
      body: SafeArea(child: child),
      bottomNavigationBar: bottomIndex == null
          ? null
          : NavigationBar(
              selectedIndex: bottomIndex!,
              onDestinationSelected: onBottomNavigation,
              destinations: const [
                NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: AppStrings.dashboard),
                NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: AppStrings.profile),
              ],
            ),
    );
  }
}

class AppHeaderCard extends StatelessWidget {
  final String name;
  final String role;
  final String? imageUrl;
  final String? department;
  final VoidCallback? onTap;

  const AppHeaderCard({
    super.key,
    required this.name,
    required this.role,
    this.imageUrl,
    this.department,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(AppColors.primary), Color(AppColors.primaryDark)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
      ),
      child: Row(
        children: [
          AppAvatar(name: name, imageUrl: imageUrl, radius: 25, lightBorder: true),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 3),
                Text(
                  department == null || department!.trim().isEmpty ? role : '$role • ${department!.trim()}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          if (onTap != null)
            IconButton(
              onPressed: onTap,
              icon: const Icon(Icons.chevron_right, color: Colors.white),
            ),
        ],
      ),
    );
  }
}

class AppAvatar extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final double radius;
  final bool lightBorder;

  const AppAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.radius = 22,
    this.lightBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: const Color(AppColors.primaryLight),
      foregroundImage: imageUrl == null || imageUrl!.trim().isEmpty ? null : NetworkImage(imageUrl!),
      child: Text(
        name.isEmpty ? '?' : name.trim()[0].toUpperCase(),
        style: TextStyle(
          color: const Color(AppColors.primary),
          fontWeight: FontWeight.w800,
          fontSize: radius * .55,
        ),
      ),
    );

    if (!lightBorder) return avatar;

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
      child: avatar,
    );
  }
}

class AppSectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const AppSectionTitle({super.key, required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700))),
        if (onSeeAll != null) TextButton(onPressed: onSeeAll, child: const Text(AppStrings.seeAll)),
      ],
    );
  }
}

class AppStatusChip extends StatelessWidget {
  final String status;

  const AppStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final normalized = status.toUpperCase();
    Color bg;
    Color fg;
    switch (normalized) {
      case AppStrings.approved:
        bg = const Color(AppColors.softGreen);
        fg = const Color(AppColors.success);
        break;
      case AppStrings.rejected:
        bg = const Color(0xFFFFE9EC);
        fg = const Color(AppColors.danger);
        break;
      case AppStrings.pending:
        bg = const Color(AppColors.softOrange);
        fg = const Color(AppColors.warning);
        break;
      default:
        bg = const Color(AppColors.primaryLight);
        fg = const Color(AppColors.primary);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(normalized, style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.w800)),
    );
  }
}

class AppStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color background;

  const AppStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(AppDimens.smallRadius)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: const Color(AppColors.primary)),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 3),
            Text(label, style: const TextStyle(fontSize: 11, color: Color(AppColors.mutedText))),
          ],
        ),
      ),
    );
  }
}

class AppInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const AppInfoRow({super.key, required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: const Color(AppColors.lavender), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 17, color: const Color(AppColors.primary)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: Color(AppColors.mutedText))),
                const SizedBox(height: 2),
                Text(AppFormatters.value(value), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AppActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const AppActionCard({super.key, required this.title, required this.subtitle, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppDimens.cardRadius),
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: const Color(AppColors.primaryLight), borderRadius: BorderRadius.circular(13)),
                child: Icon(icon, color: const Color(AppColors.primary)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(AppColors.mutedText))),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(AppColors.mutedText)),
            ],
          ),
        ),
      ),
    );
  }
}

class AppSelectOption<T> {
  final T value;
  final String label;

  const AppSelectOption({required this.value, required this.label});
}

class AppAdaptiveSelect<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<AppSelectOption<T>> options;
  final ValueChanged<T?> onChanged;
  final String? hintText;
  final String? errorText;

  const AppAdaptiveSelect({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.hintText,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return DropdownButtonFormField<T>(
        initialValue: value,
        decoration: InputDecoration(labelText: label, errorText: errorText),
        items: options.map((option) => DropdownMenuItem<T>(value: option.value, child: Text(option.label))).toList(),
        onChanged: onChanged,
      );
    }

    return FormField<T>(
      initialValue: value,
      validator: (_) => errorText,
      builder: (field) {
        final matches = options.where((option) => option.value == value);
        final selected = matches.isEmpty ? null : matches.first;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(AppDimens.smallRadius),
              onTap: () async {
                final selectedValue = await showModalBottomSheet<T>(
                  context: context,
                  showDragHandle: true,
                  builder: (sheetContext) => SafeArea(
                    child: ListView(
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(bottom: 12),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                          child: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                        ),
                        ...options.map(
                          (option) => ListTile(
                            title: Text(option.label),
                            trailing: option.value == value ? const Icon(Icons.check, color: Color(AppColors.primary)) : null,
                            onTap: () => Navigator.pop(sheetContext, option.value),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
                if (selectedValue != null) onChanged(selectedValue);
              },
              child: InputDecorator(
                decoration: InputDecoration(labelText: label, errorText: field.errorText),
                child: Text(
                  selected?.label ?? hintText ?? AppStrings.notAvailable,
                  style: TextStyle(color: selected == null ? const Color(AppColors.mutedText) : const Color(AppColors.text)),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class AppDialogs {
  AppDialogs._();

  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = AppStrings.delete,
    String cancelLabel = AppStrings.cancel,
  }) async {
    if (kIsWeb) {
      return await showDialog<bool>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: Text(title),
              content: Text(message),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(cancelLabel)),
                FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(confirmLabel)),
              ],
            ),
          ) ??
          false;
    }

    return await showModalBottomSheet<bool>(
          context: context,
          showDragHandle: true,
          builder: (sheetContext) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text(message, style: const TextStyle(color: Color(AppColors.mutedText))),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(sheetContext, false), child: Text(cancelLabel))),
                      const SizedBox(width: 12),
                      Expanded(child: FilledButton(onPressed: () => Navigator.pop(sheetContext, true), child: Text(confirmLabel))),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ) ??
        false;
  }

  static Future<String?> textInput(
    BuildContext context, {
    required String title,
    required String label,
    required String confirmLabel,
    String? initialValue,
    bool requiredValue = false,
  }) async {
    final controller = TextEditingController(text: initialValue ?? '');

    Future<String?> finish(BuildContext dialogContext) async {
      final value = controller.text.trim();
      if (requiredValue && value.isEmpty) return null;
      Navigator.pop(dialogContext, value);
      return value;
    }

    if (kIsWeb) {
      final result = await showDialog<String>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(title),
          content: TextField(controller: controller, maxLines: 4, autofocus: true, decoration: InputDecoration(labelText: label)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text(AppStrings.cancel)),
            FilledButton(onPressed: () async => finish(dialogContext), child: Text(confirmLabel)),
          ],
        ),
      );
      controller.dispose();
      return result;
    }

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.viewInsetsOf(sheetContext).bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            TextField(controller: controller, maxLines: 4, autofocus: true, decoration: InputDecoration(labelText: label)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(sheetContext), child: const Text(AppStrings.cancel))),
                const SizedBox(width: 12),
                Expanded(child: FilledButton(onPressed: () async => finish(sheetContext), child: Text(confirmLabel))),
              ],
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    return result;
  }
}
