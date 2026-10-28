import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../common/constants/app_constants.dart';
import '../../common/widgets/app_toast.dart';
import '../../common/widgets/app_ui.dart';
import '../../core/providers/department_provider.dart';
import '../../core/providers/employee_provider.dart';
import '../../models/employee.dart';

class EmployeeFormScreen extends ConsumerStatefulWidget {
  final int? employeeId;
  const EmployeeFormScreen({super.key, this.employeeId});
  bool get isEdit => employeeId != null;

  @override
  ConsumerState<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends ConsumerState<EmployeeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _code = TextEditingController();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _department = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _addressFocus = FocusNode();

  String _role = UserRole.employee;
  int? _departmentId;
  int? _managerId;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(departmentProvider.notifier).loadDepartments();
      await ref.read(employeeProvider.notifier).loadEmployees();
      if (widget.isEdit) await ref.read(employeeProvider.notifier).loadEmployee(widget.employeeId!);
    });
  }

  @override
  void dispose() {
    for (final controller in [_code, _name, _email, _department, _phone, _address]) {
      controller.dispose();
    }
    for (final node in [_nameFocus, _emailFocus, _phoneFocus, _addressFocus]) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeState = ref.watch(employeeProvider);
    final departmentState = ref.watch(departmentProvider);

    if (widget.isEdit && !_loaded && employeeState.selectedEmployee != null) {
      final employee = employeeState.selectedEmployee!;
      _code.text = employee.employeeCode;
      _name.text = employee.name;
      _email.text = employee.email;
      _department.text = employee.department ?? '';
      _phone.text = employee.phone ?? '';
      _address.text = employee.address ?? '';
      _role = employee.role;
      _departmentId = employee.departmentId;
      _managerId = employee.managerId;
      _loaded = true;
    }

    final managers = employeeState.employees.where((e) => e.role == UserRole.manager && e.id != widget.employeeId && e.isActive).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    final departmentOptions =
        departmentState.departments.where((d) => d.isActive).map((d) => AppSelectOption<int>(value: d.id, label: '${d.name} (${d.code})')).toList();

    final managerOptions = managers.map((e) => AppSelectOption<int>(value: e.id, label: '${e.name} (${e.employeeCode})')).toList();

    final roleOptions = <AppSelectOption<String>>[
      const AppSelectOption(value: UserRole.employee, label: UserRole.employee),
      const AppSelectOption(value: UserRole.manager, label: UserRole.manager),
    ];
    if (widget.isEdit && _role == UserRole.hrAdmin) {
      roleOptions.add(const AppSelectOption(value: UserRole.hrAdmin, label: UserRole.hrAdmin));
    }

    return Scaffold(
      backgroundColor: const Color(AppColors.background),
      appBar: AppBar(title: Text(widget.isEdit ? AppStrings.edit : AppStrings.addEmployee), leading: const AppBackButton()),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
          children: [
            Text(
              widget.isEdit ? 'Update employee information.' : 'Add a new employee to your organization.',
              style: const TextStyle(color: Color(AppColors.mutedText)),
            ),
            const SizedBox(height: 18),
            if (!widget.isEdit) ...[
              TextFormField(
                controller: _code,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _nameFocus.requestFocus(),
                validator: (value) => value?.trim().isEmpty == true ? '${AppStrings.employeeCode} is required' : null,
                decoration: const InputDecoration(labelText: AppStrings.employeeCode),
              ),
              const SizedBox(height: 12),
            ],
            TextFormField(
              controller: _name,
              focusNode: _nameFocus,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => _emailFocus.requestFocus(),
              validator: (value) => value?.trim().isEmpty == true ? '${AppStrings.name} is required' : null,
              decoration: const InputDecoration(labelText: AppStrings.name),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _email,
              focusNode: _emailFocus,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => _phoneFocus.requestFocus(),
              validator: (value) => value?.trim().isEmpty == true ? '${AppStrings.email} is required' : null,
              decoration: const InputDecoration(labelText: AppStrings.email),
            ),
            const SizedBox(height: 12),
            if (_role == UserRole.hrAdmin && widget.isEdit)
              const InputDecorator(
                decoration: InputDecoration(labelText: AppStrings.role),
                child: Text(AppStrings.hrAdminLabel),
              )
            else
              AppAdaptiveSelect<String>(
                label: AppStrings.role,
                value: _role,
                options: roleOptions,
                onChanged: (value) {
                  setState(() {
                    _role = value ?? UserRole.employee;
                    if (_role != UserRole.employee) _managerId = null;
                  });
                },
              ),
            const SizedBox(height: 12),
            AppAdaptiveSelect<int>(
              label: AppStrings.department,
              value: _departmentId,
              options: departmentOptions,
              hintText: AppStrings.notAvailable,
              onChanged: (value) {
                setState(() {
                  _departmentId = value;
                  final match = departmentState.departments.where((d) => d.id == value);
                  _department.text = match.isEmpty ? '' : match.first.name;
                });
              },
            ),
            const SizedBox(height: 12),
            if (_role == UserRole.employee) ...[
              AppAdaptiveSelect<int>(
                label: AppStrings.manager,
                value: _managerId,
                options: managerOptions,
                hintText: AppStrings.notAvailable,
                onChanged: (value) => setState(() => _managerId = value),
              ),
              const SizedBox(height: 12),
            ],
            TextFormField(
              controller: _phone,
              focusNode: _phoneFocus,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              maxLength: 10,
              onFieldSubmitted: (_) => _addressFocus.requestFocus(),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return null;
                return RegExp(r'^\d{10}$').hasMatch(text) ? null : AppStrings.invalidPhone;
              },
              decoration: const InputDecoration(labelText: AppStrings.phone, counterText: ''),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _address,
              focusNode: _addressFocus,
              maxLines: 3,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(labelText: AppStrings.address),
            ),
            const SizedBox(height: 22),
            FilledButton(
              onPressed: employeeState.isLoading ? null : _submit,
              child: employeeState.isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(widget.isEdit ? AppStrings.saveChanges : AppStrings.addEmployee),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.isEdit) {
      await ref.read(employeeProvider.notifier).updateEmployee(
            widget.employeeId!,
            EmployeeUpdateRequest(
              name: _name.text.trim(),
              email: _email.text.trim(),
              role: _role,
              department: _department.text.trim().isEmpty ? null : _department.text.trim(),
              phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
              address: _address.text.trim().isEmpty ? null : _address.text.trim(),
              departmentId: _departmentId,
              managerId: _role == UserRole.employee ? _managerId : null,
            ),
          );
    } else {
      await ref.read(employeeProvider.notifier).createEmployee(
            EmployeeCreateRequest(
              employeeCode: _code.text.trim(),
              name: _name.text.trim(),
              email: _email.text.trim(),
              role: _role,
              department: _department.text.trim().isEmpty ? null : _department.text.trim(),
              phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
              address: _address.text.trim().isEmpty ? null : _address.text.trim(),
              departmentId: _departmentId,
              managerId: _role == UserRole.employee ? _managerId : null,
            ),
          );
    }

    if (!mounted) return;
    final error = ref.read(employeeProvider).errorMessage;
    if (error != null) {
      AppToast.error(context, error);
      return;
    }
    context.pop(true);
  }
}
