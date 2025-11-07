import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humainity_flutter/core/providers/auth_provider.dart'; // *** REFACTOR ***
import 'package:humainity_flutter/core/theme/app_colors.dart';
import 'package:humainity_flutter/core/utils/responsive.dart';
import 'package:humainity_flutter/widgets/ui/app_button.dart';
import 'package:humainity_flutter/widgets/ui/app_dropdown.dart';
import 'package:humainity_flutter/widgets/ui/app_text_field.dart';

// *** REFACTOR *** - Converted to ConsumerStatefulWidget
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool isLogin = true;
  final _formKey = GlobalKey<FormState>();

  String _email = '';
  String _password = '';
  String _companyName = '';
  String _industry = '';

  void _switchMode() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  // *** REFACTOR *** - Updated submit logic
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    final notifier = ref.read(authNotifierProvider.notifier);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      if (isLogin) {
        await notifier.signIn(_email, _password);
        // On success, the GoRouter redirect will handle navigation
        // automatically because it's listening to the auth state.
      } else {
        await notifier.signUp(
          email: _email,
          password: _password,
          data: {
            'company_name': _companyName,
            'industry': _industry,
          },
        );
        // On sign up, show a message.
        // The user might need to confirm their email.
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text(
                'Sign up successful! Please check your email for confirmation.'),
            backgroundColor: Colors.green,
          ),
        );
        // Switch to login mode
        setState(() {
          isLogin = true;
        });
      }
    } catch (e) {
      // Handle and show error
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.destructive,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // *** REFACTOR *** - Watch auth state for loading and errors
    final authState = ref.watch(authNotifierProvider);

    // Show error snackbar if error state changes
    ref.listen<AuthScreenState>(authNotifierProvider, (previous, next) {
      if (next.error != null && previous?.error != next.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.destructive,
          ),
        );
      }
    });

    return Scaffold(
      body: Center(
        child: WebContainer(
          maxWidth: 1000,
          child: Row(
            children: [
              if (Responsive.isDesktop(context))
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.gradientPrimary,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome to HumAInity.ai',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isLogin
                              ? 'Log in to manage your AI agents and campaigns.'
                              : 'Join us and start building powerful conversational experiences.',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Image.asset(
                          'assets/images/ai-sales-agent.jpg',
                          height: 250,
                        ),
                      ],
                    ),
                  ),
                ),
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.only(
                      topLeft: Responsive.isDesktop(context)
                          ? Radius.zero
                          : const Radius.circular(12),
                      bottomLeft: Responsive.isDesktop(context)
                          ? Radius.zero
                          : const Radius.circular(12),
                      topRight: const Radius.circular(12),
                      bottomRight: const Radius.circular(12),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isLogin ? 'Sign In' : 'Create Account',
                        style: const TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 32),
                      _buildAuthForm(),
                      const SizedBox(height: 24),
                      AppButton(
                        text: isLogin ? 'Login' : 'Sign Up',
                        onPressed: authState.isLoading ? null : _submit, // Disable on load
                        isLoading: authState.isLoading, // Show loading spinner
                        width: double.infinity,
                      ),
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: authState.isLoading ? null : _switchMode, // Disable on load
                        child: Text(
                          isLogin
                              ? 'Don\'t have an account? Sign Up'
                              : 'Already have an account? Sign In',
                          style: const TextStyle(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          AppTextField(
            labelText: 'Email',
            hintText: 'name@example.com',
            keyboardType: TextInputType.emailAddress,
            onSaved: (value) => _email = value!,
            validator: (value) =>
            value!.isEmpty || !value.contains('@') ? 'Enter a valid email' : null,
          ),
          const SizedBox(height: 16),
          AppTextField(
            labelText: 'Password',
            hintText: '••••••••',
            obscureText: true,
            onSaved: (value) => _password = value!,
            validator: (value) => value!.isEmpty || value.length < 6
                ? 'Password must be at least 6 characters'
                : null,
          ),
          if (!isLogin) ...[
            const SizedBox(height: 16),
            AppTextField(
              labelText: 'Company Name',
              hintText: 'Your Business Name',
              onSaved: (value) => _companyName = value!,
              validator: (value) =>
              value!.isEmpty ? 'Company name is required' : null,
            ),
            const SizedBox(height: 16),
            AppDropdown<String>(
              labelText: 'Industry',
              value: _industry.isEmpty ? null : _industry,
              onChanged: (value) => setState(() => _industry = value!),
              hint: const Text('Select type'),
              items: const [
                DropdownMenuItem(value: 'ecommerce', child: Text('E-commerce')),
                DropdownMenuItem(value: 'finance', child: Text('Finance')),
                DropdownMenuItem(value: 'healthcare', child: Text('Healthcare')),
                DropdownMenuItem(value: 'other', child: Text('Other')),
              ],
              validator: (value) =>
              value == null ? 'Industry selection is required' : null,
            ),
          ],
        ],
      ),
    );
  }
}