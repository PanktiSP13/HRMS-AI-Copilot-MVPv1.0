import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../common/constants/app_constants.dart';
import '../../common/widgets/app_toast.dart';
import '../../common/widgets/app_ui.dart';
import '../../common/widgets/responsive_layout.dart';
import '../../core/network/api_config.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/profile_provider.dart';
import '../../models/employee.dart';
import '../../models/profile.dart';

/// [ProfileScreen] displays user profile details, avatar upload, and personal info management.
///
/// Features:
/// - Displays profile avatar, employee code, contact details, and organization info.
/// - Allows changing profile photo via ImagePicker.
/// - Edits phone number and address details.
/// - On desktop, renders contact and personal info cards side-by-side in a 2-column layout.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(profileProvider.notifier).loadProfile());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileProvider);
    final user = ref.watch(authProvider).user;
    final employee = state.profile;
    final isDesktop = AppBreakpoints.isDesktop(context);

    if (state.isLoading && employee == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (employee == null) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.profile), leading: const AppBackButton()),
        body: Center(child: Text(state.errorMessage ?? AppStrings.noData)),
      );
    }

    final imageUrl = employee.profileImageUrl == null ? null : '${AppConfig.apiBaseUrl}${employee.profileImageUrl}';

    return Scaffold(
      backgroundColor: const Color(AppColors.background),
      appBar: AppBar(title: const Text(AppStrings.profile), leading: const AppBackButton()),
      body: RefreshIndicator(
        onRefresh: () => ref.read(profileProvider.notifier).loadProfile(),
        child: ResponsiveCenter(
          maxWidth: 900,
          padding: EdgeInsets.fromLTRB(
            isDesktop ? 28 : 18,
            isDesktop ? 20 : 8,
            isDesktop ? 28 : 18,
            30,
          ),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              // Avatar & Profile Header Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(AppColors.primary), Color(AppColors.primaryDark)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppDimens.headerRadius),
                ),
                child: Column(
                  children: [
                    AppAvatar(name: employee.name, imageUrl: imageUrl, radius: 48, lightBorder: true),
                    const SizedBox(height: 14),
                    Text(employee.name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(employee.role, style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                      child: Text(employee.employeeCode, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: OutlinedButton.icon(
                  onPressed: state.isLoading ? null : _pickAndUploadProfileImage,
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Change Profile Image'),
                ),
              ),
              const SizedBox(height: 20),

              // Side-by-side or stacked profile information cards
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AppSectionTitle(title: AppStrings.contactInfo),
                          const SizedBox(height: 8),
                          _buildContactCard(employee),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AppSectionTitle(title: AppStrings.personalInfo),
                          const SizedBox(height: 8),
                          _buildPersonalCard(employee, user?.department),
                        ],
                      ),
                    ),
                  ],
                )
              else ...[
                const AppSectionTitle(title: AppStrings.contactInfo),
                const SizedBox(height: 8),
                _buildContactCard(employee),
                const SizedBox(height: 18),
                const AppSectionTitle(title: AppStrings.personalInfo),
                const SizedBox(height: 8),
                _buildPersonalCard(employee, user?.department),
              ],
              const SizedBox(height: 24),

              // Action buttons row (Edit Profile & Sign Out)
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _editProfile(employee.phone, employee.address),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text(AppStrings.saveChanges),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _signOut,
                      icon: const Icon(Icons.logout, color: Color(AppColors.danger)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(AppColors.danger),
                        side: const BorderSide(color: Color(0xFFFFCDD2)),
                      ),
                      label: const Text(AppStrings.signOut),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds contact details card widget (Email, Phone, Address).
  Widget _buildContactCard(Employee employee) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            AppInfoRow(icon: Icons.mail_outline, label: AppStrings.email, value: employee.email),
            AppInfoRow(icon: Icons.phone_outlined, label: AppStrings.phone, value: employee.phone ?? ''),
            AppInfoRow(icon: Icons.location_on_outlined, label: AppStrings.address, value: employee.address ?? ''),
          ],
        ),
      ),
    );
  }

  /// Builds personal and organizational details card widget (Department, Role, Manager).
  Widget _buildPersonalCard(Employee employee, String? fallbackDept) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            AppInfoRow(icon: Icons.business_outlined, label: AppStrings.department, value: employee.department ?? fallbackDept ?? ''),
            AppInfoRow(icon: Icons.badge_outlined, label: AppStrings.role, value: employee.role),
            AppInfoRow(icon: Icons.person_outline, label: AppStrings.managerName, value: employee.managerName ?? ''),
            AppInfoRow(
              icon: Icons.verified_user_outlined,
              label: AppStrings.status,
              value: employee.isActive ? AppStrings.active : AppStrings.inactive,
            ),
          ],
        ),
      ),
    );
  }

  /// Image picker helper for updating user avatar image.
  Future<void> _pickAndUploadProfileImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      final file = MultipartFile.fromBytes(bytes, filename: picked.name);
      await ref.read(profileProvider.notifier).uploadAvatar(file);

      if (!mounted) return;
      final error = ref.read(profileProvider).errorMessage;
      if (error != null) {
        AppToast.error(context, error);
      } else {
        AppToast.success(context, AppStrings.profileImageUpdated);
      }
    } catch (_) {
      if (mounted) AppToast.error(context, AppStrings.imagePickerUnavailable);
    }
  }

  /// Opens bottom sheet modal to update phone number or address.
  Future<void> _editProfile(String? phone, String? address) async {
    final phoneController = TextEditingController(text: phone ?? '');
    final addressController = TextEditingController(text: address ?? '');
    final phoneFocus = FocusNode();
    final addressFocus = FocusNode();

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => ResponsiveCenter(
        maxWidth: 600,
        child: Padding(
          padding: EdgeInsets.fromLTRB(18, 0, 18, MediaQuery.viewInsetsOf(sheetContext).bottom + 24),
          child: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(AppStrings.edit, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 18),
                TextFormField(
                  controller: phoneController,
                  focusNode: phoneFocus,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  maxLength: 10,
                  onChanged: (_) {},
                  onFieldSubmitted: (_) => addressFocus.requestFocus(),
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) return null;
                    if (!RegExp(r'^\d{10}$').hasMatch(text)) return AppStrings.invalidPhone;
                    return null;
                  },
                  decoration: const InputDecoration(labelText: AppStrings.phone, counterText: ''),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: addressController,
                  focusNode: addressFocus,
                  maxLines: 3,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(labelText: AppStrings.address),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(sheetContext, false), child: const Text(AppStrings.cancel))),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () async {
                          final phoneText = phoneController.text.trim();
                          if (phoneText.isNotEmpty && !RegExp(r'^\d{10}$').hasMatch(phoneText)) {
                            AppToast.error(sheetContext, AppStrings.invalidPhone);
                            return;
                          }
                          await ref.read(profileProvider.notifier).updateProfile(
                                ProfileUpdateRequest(
                                  phone: phoneText.isEmpty ? null : phoneText,
                                  address: addressController.text.trim().isEmpty ? null : addressController.text.trim(),
                                ),
                              );
                          if (!sheetContext.mounted) return;
                          final error = ref.read(profileProvider).errorMessage;
                          if (error != null) {
                            AppToast.error(sheetContext, error);
                            return;
                          }
                          Navigator.pop(sheetContext, true);
                        },
                        child: const Text(AppStrings.save),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    phoneController.dispose();
    addressController.dispose();
    phoneFocus.dispose();
    addressFocus.dispose();

    if (result == true && mounted) AppToast.success(context, AppStrings.profileUpdated);
  }

  /// Prompts sign-out confirmation dialog and logs out.
  Future<void> _signOut() async {
    final confirmed = await AppDialogs.confirm(
      context,
      title: AppStrings.signOut,
      message: AppStrings.signOutConfirm,
      confirmLabel: AppStrings.signOut,
    );
    if (!confirmed || !mounted) return;
    await ref.read(authProvider.notifier).logout();
  }
}
