import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../common/constants/app_constants.dart';
import '../../common/widgets/responsive_layout.dart';
import '../../core/providers/auth_provider.dart';

/// [AuthScreen] provides the user authentication / login portal.
///
/// Features:
/// - Email & password authentication with input validation.
/// - Obscured password toggle button.
/// - Error alert banner display for invalid credentials or inactive accounts.
/// - Centered responsive card widget (max-width 450px) on desktop viewports.
class AuthScreen extends HookConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = useTextEditingController();
    final password = useTextEditingController();
    final passwordFocus = useFocusNode();
    final obscure = useState(true);
    final authState = ref.watch(authProvider);
    final loading = authState.status == AuthStatus.loading;
    final isDesktop = AppBreakpoints.isDesktop(context);

    /// Async login handler triggering Riverpod authProvider login action.
    Future<void> login() async {
      if (email.text.trim().isEmpty || password.text.isEmpty) return;
      await ref.read(authProvider.notifier).login(
            email: email.text.trim(),
            password: password.text,
          );

      if (!context.mounted) return;
      if (ref.read(authProvider).status == AuthStatus.authenticated) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          email.clear();
          password.clear();
        });
      }
    }

    String? displayError = authState.errorMessage;
    if (displayError?.toLowerCase().contains('inactive') == true) {
      displayError = AppStrings.userDeactivated;
    }

    return Scaffold(
      backgroundColor: const Color(AppColors.background),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isDesktop ? 32 : 24),
          child: ResponsiveCenter(
            maxWidth: 450,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo Badge
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: const Color(AppColors.primary),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(AppColors.primary).withAlpha(60),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.work_outline, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 20),
                const Text(
                  AppStrings.appName,
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Manage people, leave and policies in one place.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(AppColors.mutedText)),
                ),
                const SizedBox(height: 32),

                // Login Form Card
                Card(
                  elevation: isDesktop ? 2 : 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (displayError != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE9EC),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              displayError,
                              style: const TextStyle(
                                color: Color(AppColors.danger),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        TextField(
                          controller: email,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) => passwordFocus.requestFocus(),
                          decoration: const InputDecoration(
                            labelText: AppStrings.email,
                            prefixIcon: Icon(Icons.mail_outline),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: password,
                          focusNode: passwordFocus,
                          obscureText: obscure.value,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => login(),
                          decoration: InputDecoration(
                            labelText: AppStrings.password,
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              onPressed: () => obscure.value = !obscure.value,
                              icon: Icon(obscure.value ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: loading ? null : login,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: loading
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text(AppStrings.login, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
