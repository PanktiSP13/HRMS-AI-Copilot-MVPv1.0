import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../common/constants/app_constants.dart';
import '../../common/formatters.dart';
import '../../common/widgets/app_toast.dart';
import '../../common/widgets/app_ui.dart';
import '../../common/widgets/responsive_layout.dart';
import '../../core/providers/profile_provider.dart';
import '../../models/leave_request.dart';

class LeaveFormScreen extends ConsumerStatefulWidget {
  const LeaveFormScreen({super.key});

  @override
  ConsumerState<LeaveFormScreen> createState() => _LeaveFormScreenState();
}

class _LeaveFormScreenState extends ConsumerState<LeaveFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reason = TextEditingController();
  final _comment = TextEditingController();
  final _commentFocus = FocusNode();
  String _leaveType = LeaveType.annual;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  @override
  void dispose() {
    _reason.dispose();
    _comment.dispose();
    _commentFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileProvider);
    final leaveOptions = LeaveType.values.map((type) => AppSelectOption<String>(value: type, label: type)).toList();
    final isDesktop = AppBreakpoints.isDesktop(context);

    return Scaffold(
      backgroundColor: const Color(AppColors.background),
      appBar: AppBar(title: const Text(AppStrings.applyLeave), leading: const AppBackButton()),
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
              const Text('Choose your leave dates and add a short reason.', style: TextStyle(color: Color(AppColors.mutedText))),
              const SizedBox(height: 18),
              AppAdaptiveSelect<String>(
                label: AppStrings.leave,
                value: _leaveType,
                options: leaveOptions,
                onChanged: (value) => setState(() => _leaveType = value ?? LeaveType.annual),
              ),
              const SizedBox(height: 12),
              _dateField(AppStrings.startDate, _startDate, (d) {
                setState(() {
                  _startDate = d;
                  if (_endDate.isBefore(d)) _endDate = d;
                });
              }),
              const SizedBox(height: 12),
              _dateField(AppStrings.endDate, _endDate, (d) => setState(() => _endDate = d)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _reason,
                maxLines: 3,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _commentFocus.requestFocus(),
                validator: (value) => value?.trim().isEmpty == true ? '${AppStrings.reason} is required' : null,
                decoration: const InputDecoration(labelText: AppStrings.reason),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _comment,
                focusNode: _commentFocus,
                maxLines: 3,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(labelText: AppStrings.comment),
              ),
              const SizedBox(height: 22),
              FilledButton(
                onPressed: state.isLoading ? null : _submit,
                child: state.isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text(AppStrings.submit),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dateField(String label, DateTime value, ValueChanged<DateTime> onChanged) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppDimens.smallRadius),
      onTap: () async {
        final selected = await showDatePicker(
          context: context,
          firstDate: DateTime.now(),
          lastDate: DateTime(DateTime.now().year + 2),
          initialDate: value,
        );
        if (selected != null) onChanged(selected);
      },
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, size: 18, color: Color(AppColors.mutedText)),
            const SizedBox(width: 10),
            Text(AppFormatters.date(value), style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(profileProvider.notifier).createLeaveRequest(
          LeaveRequestCreate(
            leaveType: _leaveType,
            startDate: _startDate,
            endDate: _endDate,
            reason: _reason.text.trim(),
            comment: _comment.text.trim().isEmpty ? null : _comment.text.trim(),
          ),
        );

    if (!mounted) return;
    final error = ref.read(profileProvider).errorMessage;
    if (error != null) {
      AppToast.error(context, error);
      return;
    }
    context.pop(true);
  }
}
