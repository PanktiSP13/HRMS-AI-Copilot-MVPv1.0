import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hrms_ai_copilot/features/policies/policy_permissions.dart';

import '../../common/constants/app_constants.dart';
import '../../common/formatters.dart';
import '../../common/widgets/app_toast.dart';
import '../../common/widgets/app_ui.dart';
import '../../common/widgets/responsive_layout.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/policy_provider.dart';
import '../../core/router/app_router.dart';

class PolicyDetailScreen extends ConsumerStatefulWidget {
  final int policyId;

  const PolicyDetailScreen({
    super.key,
    required this.policyId,
  });

  @override
  ConsumerState<PolicyDetailScreen> createState() => _PolicyDetailScreenState();
}

class _PolicyDetailScreenState extends ConsumerState<PolicyDetailScreen> {
  static const int _previewMaxLines = 8;
  static const int _previewCharacterLimit = 700;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(policyProvider.notifier).loadPolicy(widget.policyId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(policyProvider);
    final policy = state.selectedPolicy;

    final role = ref.watch(authProvider).user?.role;
    final canManagePolicies = PolicyPermissions.canEdit(role);
    final canDownload = PolicyPermissions.canDownload(role);
    final hasPdf = policy?.pdfFileName?.isNotEmpty == true;
    final isDesktop = AppBreakpoints.isDesktop(context);

    return Scaffold(
      backgroundColor: const Color(AppColors.background),
      appBar: AppBar(
        title: const Text(AppStrings.details),
        automaticallyImplyLeading: !isDesktop,
      ),
      body: state.isLoading && policy == null
          ? const Center(child: CircularProgressIndicator())
          : policy == null
              ? Center(
                  child: Text(
                    state.errorMessage ?? AppStrings.noData,
                  ),
                )
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
                                backgroundColor: Color(AppColors.softGreen),
                                child: Icon(
                                  Icons.policy_outlined,
                                  color: Color(AppColors.success),
                                  size: 30,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                policy.name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              AppStatusChip(
                                status: policy.isActive ? AppStrings.active : AppStrings.inactive,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 5,
                          ),
                          child: Column(
                            children: [
                              AppInfoRow(
                                icon: Icons.category_outlined,
                                label: AppStrings.category,
                                value: policy.category,
                              ),
                              AppInfoRow(
                                icon: Icons.tag_outlined,
                                label: AppStrings.version,
                                value: policy.version,
                              ),
                              AppInfoRow(
                                icon: Icons.calendar_today_outlined,
                                label: AppStrings.createdAt,
                                value: AppFormatters.date(policy.createdAt),
                              ),
                              if (hasPdf)
                                AppInfoRow(
                                  icon: Icons.picture_as_pdf_outlined,
                                  label: AppStrings.fileName,
                                  value: policy.pdfFileName!,
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildContentPreview(policy.content),
                      if (canDownload && hasPdf) ...[
                        const SizedBox(height: 18),
                        OutlinedButton.icon(
                          onPressed: state.isDownloading
                              ? null
                              : () async {
                                  final success = await ref.read(policyProvider.notifier).downloadPolicy(
                                        policyId: policy.id,
                                        fileName: policy.pdfFileName!,
                                      );

                                  if (!context.mounted) return;

                                  if (success) {
                                    AppToast.success(
                                      context,
                                      AppStrings.downloadStarted,
                                    );
                                  } else {
                                    AppToast.error(
                                      context,
                                      ref.read(policyProvider).errorMessage ?? AppStrings.policyUploadFailed,
                                    );
                                  }
                                },
                          icon: state.isDownloading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.download_outlined),
                          label: Text(
                            state.isDownloading ? AppStrings.downloading : AppStrings.downloadPdf,
                          ),
                        ),
                      ],
                      if (canManagePolicies) ...[
                        const SizedBox(height: 10),
                        FilledButton.icon(
                          onPressed: () async {
                            final changed = await context.push<bool>(
                              AppRoutes.policyEdit(policy.id),
                            );

                            if (changed == true) {
                              if (!context.mounted) return;

                              await ref.read(policyProvider.notifier).loadPolicy(policy.id);
                              await ref.read(policyProvider.notifier).loadPolicies();

                              if (context.mounted) {
                                AppToast.success(
                                  context,
                                  AppStrings.policyUpdated,
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text(AppStrings.edit),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: () => _delete(policy.id),
                          icon: const Icon(Icons.delete_outline),
                          label: const Text(AppStrings.delete),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildContentPreview(String content) {
    final shouldShowReadMore = content.length > _previewCharacterLimit;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              AppStrings.content,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(
                maxHeight: 190,
              ),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(AppColors.background),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                content,
                maxLines: _previewMaxLines,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(height: 1.55),
              ),
            ),
            if (shouldShowReadMore) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _showFullContent(content),
                  icon: const Icon(Icons.unfold_more_outlined),
                  label: const Text('Read more'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showFullContent(String content) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.72,
          minChildSize: 0.45,
          maxChildSize: 0.94,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            AppStrings.content,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
                      child: Text(
                        content,
                        style: const TextStyle(height: 1.55),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _delete(int id) async {
    final confirmed = await AppDialogs.confirm(
      context,
      title: AppStrings.delete,
      message: AppStrings.confirmDelete,
    );

    if (!confirmed || !mounted) return;

    await ref.read(policyProvider.notifier).deletePolicy(id);

    if (!mounted) return;

    final error = ref.read(policyProvider).errorMessage;

    if (error != null) {
      AppToast.error(context, error);
      return;
    }

    AppToast.success(context, AppStrings.policyDeleted);
    context.pop(true);
  }
}
