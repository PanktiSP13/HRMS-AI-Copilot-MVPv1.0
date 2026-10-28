import 'package:file_picker/file_picker.dart' show FilePicker, FileType;
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
import '../../models/policy.dart';

class PolicyFormScreen extends ConsumerStatefulWidget {
  final int? policyId;

  const PolicyFormScreen({
    super.key,
    this.policyId,
  });

  bool get isEdit => policyId != null;

  @override
  ConsumerState<PolicyFormScreen> createState() => _PolicyFormScreenState();
}

class _PolicyFormScreenState extends ConsumerState<PolicyFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _category = TextEditingController();
  final _version = TextEditingController();
  final _content = TextEditingController();

  final _categoryFocus = FocusNode();
  final _versionFocus = FocusNode();

  bool _active = true;
  bool _loaded = false;

  List<int>? _selectedPdfBytes;
  String? _selectedPdfName;
  String? _existingPdfName;

  @override
  void initState() {
    super.initState();

    if (widget.isEdit) {
      Future.microtask(
        () => ref.read(policyProvider.notifier).loadPolicy(widget.policyId!),
      );
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _category.dispose();
    _version.dispose();
    _content.dispose();
    _categoryFocus.dispose();
    _versionFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(policyProvider);
    final role = ref.watch(authProvider).user?.role;
    final canUpload = PolicyPermissions.canUpload(role);
    final isDesktop = AppBreakpoints.isDesktop(context);

    if (!widget.isEdit && !canUpload) {
      return const Scaffold(
        body: Center(
          child: Text(AppStrings.permissionDenied),
        ),
      );
    }

    if (widget.isEdit && !_loaded && state.selectedPolicy != null) {
      final policy = state.selectedPolicy!;

      _name.text = policy.name;
      _category.text = policy.category;
      _version.text = policy.version;
      _content.text = policy.content;
      _active = policy.isActive;
      _existingPdfName = policy.pdfFileName;
      _loaded = true;
    }

    return Scaffold(
      backgroundColor: const Color(AppColors.background),
      appBar: AppBar(
        title: Text(
          widget.isEdit ? AppStrings.edit : AppStrings.uploadPolicyPdf,
        ),
        leading: const AppBackButton(),
      ),
      body: ResponsiveCenter(
        maxWidth: 750,
        padding: EdgeInsets.fromLTRB(
          isDesktop ? 28 : 18,
          isDesktop ? 20 : 8,
          isDesktop ? 28 : 18,
          30,
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                widget.isEdit ? 'Update company policy details.' : 'Upload a company policy PDF.',
                style: const TextStyle(
                  color: Color(AppColors.mutedText),
                ),
              ),
              const SizedBox(height: 18),
              _field(
                _name,
                AppStrings.name,
                requiredField: true,
                nextFocus: _categoryFocus,
              ),
              const SizedBox(height: 12),
              _field(
                _category,
                AppStrings.category,
                requiredField: true,
                focusNode: _categoryFocus,
                nextFocus: _versionFocus,
              ),
              const SizedBox(height: 12),
              _field(
                _version,
                AppStrings.version,
                requiredField: true,
                focusNode: _versionFocus,
                isLast: !widget.isEdit,
              ),
              const SizedBox(height: 18),
              if (!widget.isEdit) _buildPdfPicker(),
              if (widget.isEdit) ...[
                _buildContentPreview(),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _active,
                  onChanged: (value) {
                    setState(() => _active = value);
                  },
                  title: const Text(AppStrings.active),
                ),
              ],
              const SizedBox(height: 18),
              FilledButton(
                onPressed: state.isLoading || state.isUploading ? null : _submit,
                child: state.isLoading || state.isUploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        widget.isEdit ? AppStrings.saveChanges : AppStrings.upload,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPdfPicker() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.picture_as_pdf_outlined),
                SizedBox(width: 10),
                Text(
                  AppStrings.selectPolicyPdf,
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_selectedPdfName != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(AppColors.background),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.picture_as_pdf, color: Colors.red),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _selectedPdfName!,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _selectedPdfBytes = null;
                          _selectedPdfName = null;
                        });
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              )
            else
              const Text(AppStrings.noPdfSelected),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickPdf,
              icon: const Icon(Icons.upload_file_outlined),
              label: Text(
                _selectedPdfName == null ? AppStrings.choosePdf : 'Change PDF',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentPreview() {
    final content = _content.text.trim();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
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
              constraints: const BoxConstraints(
                maxHeight: 190,
              ),
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(AppColors.background),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(AppColors.border),
                ),
              ),
              child: Text(
                content.isEmpty ? 'No policy content available.' : content,
                maxLines: 8,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(height: 1.5),
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: content.isEmpty ? null : _showFullContent,
                icon: const Icon(Icons.open_in_new, size: 18),
                label: const Text('Read more'),
              ),
            ),
            if (_existingPdfName != null) ...[
              const Divider(height: 10),
              Row(
                children: [
                  const Icon(Icons.picture_as_pdf_outlined, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _existingPdfName!,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showFullContent() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.75,
            minChildSize: 0.45,
            maxChildSize: 0.95,
            builder: (context, controller) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Policy Content',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: controller,
                        child: Text(
                          _content.text,
                          style: const TextStyle(height: 1.6),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _pickPdf() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result.isEmpty) return;

      final file = result.first;
      final name = file.name;

      if (!name.toLowerCase().endsWith('.pdf')) {
        if (mounted) AppToast.error(context, AppStrings.pdfOnly);
        return;
      }

      final bytes = await file.readAsBytes();

      if (!mounted) return;

      setState(() {
        _selectedPdfBytes = bytes;
        _selectedPdfName = name;
      });
    } catch (error) {
      if (!mounted) return;
      AppToast.error(context, error.toString());
    }
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool requiredField = false,
    FocusNode? focusNode,
    FocusNode? nextFocus,
    bool isLast = false,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      textInputAction: isLast ? TextInputAction.done : TextInputAction.next,
      onFieldSubmitted: (_) => nextFocus?.requestFocus(),
      validator: requiredField
          ? (value) {
              if (value?.trim().isEmpty == true) {
                return '$label is required';
              }
              return null;
            }
          : null,
      decoration: InputDecoration(labelText: label),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.isEdit) {
      await ref.read(policyProvider.notifier).updatePolicy(
            widget.policyId!,
            PolicyUpdateRequest(
              name: _name.text.trim(),
              category: _category.text.trim(),
              version: _version.text.trim(),
              content: _content.text.trim(),
              isActive: _active,
            ),
          );
    } else {
      if (_selectedPdfBytes == null || _selectedPdfName == null) {
        AppToast.error(context, AppStrings.noPdfSelected);
        return;
      }

      final success = await ref.read(policyProvider.notifier).uploadPolicy(
            name: _name.text.trim(),
            category: _category.text.trim(),
            version: _version.text.trim(),
            fileBytes: _selectedPdfBytes!,
            fileName: _selectedPdfName!,
          );

      if (!success) {
        if (!mounted) return;
        AppToast.error(
          context,
          ref.read(policyProvider).errorMessage ?? AppStrings.policyUploadFailed,
        );
        return;
      }
    }

    if (!mounted) return;

    final error = ref.read(policyProvider).errorMessage;
    if (error != null) {
      AppToast.error(context, error);
      return;
    }

    AppToast.success(
      context,
      widget.isEdit ? AppStrings.policyUpdated : AppStrings.policyUploaded,
    );
    context.pop(true);
  }
}
