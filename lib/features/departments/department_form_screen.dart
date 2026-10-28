import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../common/constants/app_constants.dart';
import '../../common/widgets/app_toast.dart';
import '../../common/widgets/app_ui.dart';
import '../../common/widgets/responsive_layout.dart';
import '../../core/providers/department_provider.dart';
import '../../models/department.dart';

class DepartmentFormScreen extends ConsumerStatefulWidget {
  final int? departmentId;
  const DepartmentFormScreen({super.key, this.departmentId});
  bool get isEdit => departmentId != null;

  @override
  ConsumerState<DepartmentFormScreen> createState() => _DepartmentFormScreenState();
}

class _DepartmentFormScreenState extends ConsumerState<DepartmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _code = TextEditingController();
  final _description = TextEditingController();
  final _codeFocus = FocusNode();
  final _descriptionFocus = FocusNode();
  bool _active = true;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) Future.microtask(() => ref.read(departmentProvider.notifier).loadDepartment(widget.departmentId!));
  }

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    _description.dispose();
    _codeFocus.dispose();
    _descriptionFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(departmentProvider);
    final isDesktop = AppBreakpoints.isDesktop(context);

    if (widget.isEdit && !_loaded && state.selectedDepartment != null) {
      final d = state.selectedDepartment!;
      _name.text = d.name;
      _code.text = d.code;
      _description.text = d.description ?? '';
      _active = d.isActive;
      _loaded = true;
    }

    return Scaffold(
      backgroundColor: const Color(AppColors.background),
      appBar: AppBar(title: Text(widget.isEdit ? AppStrings.edit : AppStrings.addDepartment), leading: const AppBackButton()),
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
              const Text('Keep department information clear and up to date.', style: TextStyle(color: Color(AppColors.mutedText))),
              const SizedBox(height: 18),
              TextFormField(
                controller: _name,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _codeFocus.requestFocus(),
                validator: (v) => v?.trim().isEmpty == true ? '${AppStrings.name} is required' : null,
                decoration: const InputDecoration(labelText: AppStrings.name),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _code,
                focusNode: _codeFocus,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _descriptionFocus.requestFocus(),
                validator: (v) => v?.trim().isEmpty == true ? '${AppStrings.code} is required' : null,
                decoration: const InputDecoration(labelText: AppStrings.code),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _description,
                focusNode: _descriptionFocus,
                maxLines: 4,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(labelText: AppStrings.description),
              ),
              if (widget.isEdit) ...[
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _active,
                  onChanged: (value) => setState(() => _active = value),
                  title: const Text(AppStrings.active),
                ),
              ],
              const SizedBox(height: 18),
              FilledButton(
                onPressed: state.isLoading ? null : _submit,
                child: Text(widget.isEdit ? AppStrings.saveChanges : AppStrings.addDepartment),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.isEdit) {
      await ref.read(departmentProvider.notifier).updateDepartment(
            widget.departmentId!,
            DepartmentUpdateRequest(
              name: _name.text.trim(),
              code: _code.text.trim(),
              description: _description.text.trim().isEmpty ? null : _description.text.trim(),
              isActive: _active,
            ),
          );
    } else {
      await ref.read(departmentProvider.notifier).createDepartment(
            DepartmentCreateRequest(
              name: _name.text.trim(),
              code: _code.text.trim(),
              description: _description.text.trim().isEmpty ? null : _description.text.trim(),
            ),
          );
    }

    if (!mounted) return;
    final error = ref.read(departmentProvider).errorMessage;
    if (error != null) {
      AppToast.error(context, error);
      return;
    }
    context.pop(true);
  }
}
